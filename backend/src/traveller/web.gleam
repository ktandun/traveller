import cors_builder as cors
import gleam/dynamic
import gleam/http
import gleam/int
import gleam/json.{type DecodeError, type Json}
import gleam/pgo.{
  ConnectionUnavailable, ConstraintViolated, PostgresqlError,
  UnexpectedArgumentCount, UnexpectedArgumentType, UnexpectedResultType,
}
import gleam/result
import shared/constants
import shared/id.{type Id, type UserId}
import traveller/error.{type AppError, JsonDecodeError}
import traveller/sql
import wisp.{type Request, type Response}
import youid/uuid.{type Uuid}

pub type Context {
  Context(db: pgo.Connection, uuid_provider: fn() -> Uuid)
}

fn cors() {
  cors.new()
  |> cors.allow_origin("http://localhost:1234")
  |> cors.allow_header("content-type")
  |> cors.allow_method(http.Get)
  |> cors.allow_method(http.Post)
  |> cors.allow_method(http.Put)
  |> cors.allow_method(http.Delete)
}

pub fn middleware(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> wisp.Response {
  let req = wisp.method_override(req)

  use req <- cors.wisp_middleware(req, cors())

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
  next: fn(Id(UserId)) -> Response,
) {
  use user_id <- require_ok(
    wisp.get_cookie(req, constants.cookie, wisp.Signed)
    |> result.map_error(fn(_) { error.UserUnauthenticated }),
  )

  use user_id_uuid <- require_ok(
    uuid.from_string(user_id)
    |> result.map_error(fn(_) { error.InvalidUUIDString(user_id) }),
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
    error.QueryNotReturningSingleResult(e) -> todo
    error.InvalidUUIDString(e) ->
      [#("title", json.string("INVALID_UUID_STRING"))]
      |> json.object()
      |> json_with_status(400)
    error.UserUnauthenticated -> error.user_unauthenticated()
    error.InvalidLogin -> error.invalid_login()
    error.TripDoesNotExist ->
      [#("title", json.string("TRIP_DOES_NOT_EXIST"))]
      |> json.object()
      |> json_with_status(400)
    error.UserAlreadyRegistered ->
      [#("title", json.string("USER_ALREADY_REGISTERED"))]
      |> json.object()
      |> json_with_status(400)

    error.DatabaseError(query_error) -> {
      let response =
        json.object([#("title", json.string("DATABASE_ERROR"))])
        |> json_with_status(500)

      case query_error {
        ConstraintViolated(message, constraint, detail) -> {
          wisp.log_error(
            "ConstraintViolated "
            <> message
            <> " constraint: "
            <> constraint
            <> " detail: "
            <> detail,
          )
          response
        }
        PostgresqlError(code, name, message) -> {
          wisp.log_error(
            "postgresqlerror "
            <> code
            <> " name: "
            <> name
            <> " message: "
            <> message,
          )
          response
        }
        UnexpectedArgumentCount(expected, got) -> {
          wisp.log_error(
            "UnexpectedArgumentCount"
            <> " expected: "
            <> int.to_string(expected)
            <> " got: "
            <> int.to_string(got),
          )
          response
        }
        UnexpectedArgumentType(expected, got) -> {
          wisp.log_error(
            "UnexpectedArgumentType"
            <> " expected: "
            <> expected
            <> " got: "
            <> got,
          )
          response
        }
        UnexpectedResultType(e) -> {
          error_to_response(JsonDecodeError(e))
        }
        ConnectionUnavailable -> {
          wisp.log_error("ConnectionUnavailable")
          response
        }
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
