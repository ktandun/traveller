import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/json
import gleam/result
import gleam/string_builder
import traveller/error
import traveller/user
import traveller/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req)

    ["login"] -> login(req)

    _ -> wisp.not_found()
  }
}

type LoginRequest {
  LoginRequest(email: String, password: String)
}

fn login_request_decoder(json: Dynamic) {
  let decoder =
    dynamic.decode2(
      LoginRequest,
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
    )

  decoder(json)
}

fn login(req: Request) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_json(req)

  let login_request =
    login_request_decoder(json)
    |> result.map_error(with: fn(_) { error.JsonDecodeError })

  use valid_request <- web.require_ok(login_request)

  case user.login_user(valid_request.email, valid_request.password) {
    True ->
      json.object([#("success", json.bool(True))])
      |> json.to_string_builder
      |> wisp.json_response(200)
    False ->
      json.object([#("success", json.bool(False))])
      |> json.to_string_builder
      |> wisp.json_response(400)
  }
}

fn home_page(req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  let html = string_builder.from_string("Hello, Joe!")
  wisp.ok()
  |> wisp.html_body(html)
}
