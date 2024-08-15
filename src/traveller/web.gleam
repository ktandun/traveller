import gleam/dynamic.{type DecodeErrors, DecodeError}
import gleam/json.{type Json}
import gleam/pgo
import traveller/error.{type AppError, JsonDecodeError}
import wisp.{type Response}

pub type Context {
  Context(db: pgo.Connection)
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
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

pub fn require_valid_json(
  result: Result(a, DecodeErrors),
  next: fn(a) -> Response,
) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(e) -> error_to_response(JsonDecodeError(e))
  }
}

fn json_with_status(json: Json, status: Int) -> Response {
  json
  |> json.to_string_builder
  |> wisp.json_response(status)
}

pub fn error_to_response(error: AppError) -> Response {
  case error {
    error.InvalidLogin ->
      [#("error", json.string("INVALID_LOGIN"))]
      |> json.object()
      |> json_with_status(400)

    error.UserAlreadyRegistered ->
      [#("error", json.string("USER_ALREADY_REGISTERED"))]
      |> json.object()
      |> json_with_status(400)

    error.DatabaseError ->
      json.object([#("error", json.string("DATABASE_ERROR"))])
      |> json_with_status(500)

    error.JsonDecodeError(errors) -> {
      let decode_errors_json =
        json.array(errors, of: fn(error) {
          let decode_error = {
            case error {
              DecodeError(expected, found, path) -> #(expected, found, path)
            }
          }

          let #(expected, found, path) = decode_error
          json.object([
            #("expected", json.string(expected)),
            #("found", json.string(found)),
            #("path", json.array(path, of: json.string)),
          ])
        })

      [#("error", decode_errors_json)]
      |> json.object
      |> json_with_status(400)
    }
  }
}
