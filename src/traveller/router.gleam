import gleam/dynamic.{type Dynamic}
import gleam/http.{Post}
import gleam/json
import traveller/error
import traveller/user
import traveller/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    // This matches `/`.

    ["login"] -> login(req, ctx)
    ["signup"] -> signup(req, ctx)

    _ -> wisp.not_found()
  }
}

type LoginRequest {
  LoginRequest(email: String, password: String)
}

type SignupRequest {
  SignupRequest(email: String, password: String)
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

fn signup_request_decoder(json: Dynamic) {
  let decoder =
    dynamic.decode2(
      SignupRequest,
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
    )

  decoder(json)
}

fn signup(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_json(req)

  use signup_request <- web.require_valid_json(signup_request_decoder(json))
  use is_user_exists <- web.require_ok(user.is_user_exists(
    ctx,
    signup_request.email,
  ))

  case is_user_exists {
    False -> {
      use userid <- web.require_ok(user.create_user(
        ctx,
        signup_request.email,
        signup_request.password,
      ))

      json.object([#("userid", json.string(userid))])
      |> json.to_string_builder
      |> wisp.json_response(200)
    }

    True -> web.error_to_response(error.UserAlreadyRegistered)
  }
}

fn login(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_json(req)

  use login_request <- web.require_valid_json(login_request_decoder(json))

  case user.login_user(ctx, login_request.email, login_request.password) {
    Ok(is_valid) ->
      json.object([#("success", json.bool(is_valid))])
      |> json.to_string_builder
      |> wisp.json_response(200)
    Error(_) -> web.error_to_response(error.InvalidLogin)
  }
}
