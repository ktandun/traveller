import traveller/error.{type AppError}
import wisp.{type Response}

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

pub fn error_to_response(error: AppError) -> Response {
  case error {
    error.UnknownError -> wisp.unprocessable_entity()
    error.JsonDecodeError -> wisp.unprocessable_entity()
  }
}
