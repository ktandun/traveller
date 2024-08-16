import gleam/dynamic
import gleam/json.{type DecodeError, type Json}
import gleam/pgo.{
  ConnectionUnavailable, ConstraintViolated, PostgresqlError,
  UnexpectedArgumentCount, UnexpectedArgumentType, UnexpectedResultType,
}
import gleam/result
import shared/constants
import traveller/error.{type AppError, JsonDecodeError}
import traveller/sql
import wisp.{type Request, type Response}

pub type Context {
  Context(db: pgo.Connection, uuid_provider: fn() -> String)
}

pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
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
  next: fn(String) -> Response,
) {
  use cookie <- require_ok(
    wisp.get_cookie(req, constants.cookie, wisp.Signed)
    |> result.map_error(fn(_) { error.UserUnauthenticated }),
  )

  use pgo.Returned(_, rows) <- require_ok(
    sql.find_user_by_userid(ctx.db, cookie)
    |> result.map_error(fn(e) { error.DatabaseError(e) }),
  )

  let assert [row] = rows

  case row.count {
    1 -> next(cookie)
    _ -> error_to_response(error.UserUnauthenticated)
  }
}

pub fn require_valid_json(
  result: Result(a, DecodeError),
  next: fn(a) -> b,
) -> Result(b, AppError) {
  case result {
    Ok(value) -> Ok(next(value))
    Error(e) -> Error(error.JsonCodecDecodeError(e))
  }
}

fn json_with_status(json: Json, status: Int) -> Response {
  json
  |> json.to_string_builder
  |> wisp.json_response(status)
}

pub fn error_to_response(error: AppError) -> Response {
  case error {
    error.JsonCodecDecodeError(e) ->
      [#("title", json.string("JSON_CODEC_DECODE_ERROR"))]
      |> json.object()
      |> json_with_status(400)

    error.UserUnauthenticated ->
      [#("title", json.string("USER_UNAUTHENTICATED"))]
      |> json.object()
      |> json_with_status(401)

    error.InvalidLogin ->
      [#("title", json.string("INVALID_LOGIN"))]
      |> json.object()
      |> json_with_status(400)

    error.UserAlreadyRegistered ->
      [#("title", json.string("USER_ALREADY_REGISTERED"))]
      |> json.object()
      |> json_with_status(400)

    error.DatabaseError(query_error) -> {
      case query_error {
        ConstraintViolated(_message, _constraint, _detail) ->
          json.object([
            #("title", json.string("DATABASE_ERROR")),
            #("detail", json.string("constraint violated")),
          ])
          |> json_with_status(500)
        PostgresqlError(_code, _name, _message) ->
          json.object([
            #("title", json.string("DATABASE_ERROR")),
            #("detail", json.string("postgresql error")),
          ])
          |> json_with_status(500)
        UnexpectedArgumentCount(_expected, _got) ->
          json.object([
            #("title", json.string("DATABASE_ERROR")),
            #("detail", json.string("unexpected argument count")),
          ])
          |> json_with_status(500)
        UnexpectedArgumentType(_expected, _got) ->
          json.object([
            #("title", json.string("DATABASE_ERROR")),
            #("detail", json.string("unexpected argument count")),
          ])
          |> json_with_status(500)
        UnexpectedResultType(e) -> error_to_response(JsonDecodeError(e))
        ConnectionUnavailable ->
          json.object([
            #("title", json.string("DATABASE_ERROR")),
            #("detail", json.string("connection unavailable")),
          ])
          |> json_with_status(500)
      }
    }

    error.JsonDecodeError(errors) -> {
      let decode_errors_json =
        json.array(errors, of: fn(error) {
          let decode_error = {
            case error {
              dynamic.DecodeError(expected, found, path) -> #(
                expected,
                found,
                path,
              )
            }
          }

          let #(expected, found, path) = decode_error
          json.object([
            #("expected", json.string(expected)),
            #("found", json.string(found)),
            #("path", json.array(path, of: json.string)),
          ])
        })

      [#("title", json.string("DECODE_ERROR")), #("detail", decode_errors_json)]
      |> json.object
      |> json_with_status(400)
    }
  }
}
