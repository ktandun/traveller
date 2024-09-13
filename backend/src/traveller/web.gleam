import database/sql
import gleam/dynamic
import gleam/http/response
import gleam/int
import gleam/io
import gleam/json.{type DecodeError, type Json}
import gleam/pgo
import gleam/result
import shared/constants
import shared/id.{type Id, type UserId}
import simplifile
import traveller/error.{type AppError}
import wisp.{type Request, type Response}
import youid/uuid.{type Uuid}

pub type Context {
  Context(
    db: pgo.Connection,
    uuid_provider: fn() -> Uuid,
    static_directory: String,
  )
}

pub fn with_db_conn(ctx: Context, db_conn: pgo.Connection) {
  Context(..ctx, db: db_conn)
}

pub fn middleware(
  ctx: Context,
  req: Request,
  handle_request: fn(Request) -> Response,
) -> wisp.Response {
  let req = wisp.method_override(req)

  use <- wisp.log_request(req)

  use <- wisp.rescue_crashes

  use req <- wisp.handle_head(req)

  use <- wisp.serve_static(req, under: "/", from: ctx.static_directory)

  handle_request(req)
}

pub fn fallback_to_index_html(ctx: Context) {
  case simplifile.is_file(ctx.static_directory <> "/index.html") {
    Ok(True) ->
      response.new(200)
      |> response.set_header("content-type", "text/html; charset=utf-8")
      |> response.set_body(wisp.File(ctx.static_directory <> "/index.html"))
    _ -> wisp.not_found()
  }
}

pub fn try_or(
  result: Result(a, b),
  or alternative: fn() -> Response,
  then next: fn(a) -> Response,
) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(_) -> alternative()
  }
}

pub fn require_ok(
  result: Result(a, AppError),
  next: fn(a) -> Response,
) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(error) -> error_to_response(error)
  }
}

pub fn require_authenticated(
  req: Request,
  ctx: Context,
  next: fn(Id(UserId)) -> Response,
) {
  use user_id <- require_ok(
    wisp.get_cookie(req, constants.cookie, wisp.Signed)
    |> result.map_error(fn(_) { error.UserUnauthenticated }),
  )

  use user_id_uuid <- require_ok(
    uuid.from_string(user_id)
    |> result.map_error(fn(_) {
      error.VerificationFailed("Invalid UUID user id " <> user_id)
    }),
  )

  use pgo.Returned(row_count, _) <- require_ok(
    sql.find_user_by_userid(ctx.db, user_id_uuid)
    |> result.map_error(fn(e) { error.DatabaseError(e) }),
  )

  case row_count {
    1 -> next(id.to_id(user_id))
    _ -> error_to_response(error.UserUnauthenticated)
  }
}

pub fn require_valid_json(
  result: Result(a, AppError),
  next: fn(a) -> Response,
) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(e) -> error_to_response(e)
  }
}

fn json_with_status(json: Json, status: Int) -> Response {
  json
  |> json.to_string_builder
  |> wisp.json_response(status)
}

pub fn error_to_response(error: AppError) -> Response {
  case error {
    error.DecodeError(e) -> error.json_codec_decode_error(e)
    error.VerificationFailed(error_text) ->
      [
        #("title", json.string("VERIFICATION_FAILED")),
        #("detail", json.string(error_text)),
      ]
      |> json.object()
      |> json_with_status(400)
    error.ValidationFailed(field) ->
      [
        #("title", json.string("INVALID_FIELD_CONTENT")),
        #("detail", json.string(field)),
      ]
      |> json.object()
      |> json_with_status(400)
    error.BodyNotJsonError ->
      [#("title", json.string("BODY_NOT_JSON"))]
      |> json.object()
      |> json_with_status(400)
    error.QueryNotReturningSingleResult(e) ->
      [#("title", json.string("QUERY_NOT_RETURNING_SINGLE_ROW: " <> e))]
      |> json.object()
      |> json_with_status(500)
    error.UserUnauthenticated -> error.user_unauthenticated()
    error.TransactionError(e) -> error.transaction_error(e)
    error.DatabaseError(e) -> {
      error.log_query_error(e)

      json.object([#("title", json.string("DATABASE_ERROR"))])
      |> json_with_status(500)
    }
  }
}
