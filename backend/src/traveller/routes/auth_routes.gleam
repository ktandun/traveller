import gleam/http.{Post}
import gleam/json
import gleam_community/codec
import shared/auth
import traveller/error
import traveller/user
import traveller/web.{type Context}
import wisp.{type Request, type Response}

pub fn signup(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)

  let signup_request = codec.decode_string(json, auth.signup_request_codec())

  use signup_request <- web.require_valid_json(signup_request)
  use is_user_exists <- web.require_ok(user.find_user_by_email(
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

pub fn login(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)

  let login_request = codec.decode_string(json, auth.login_request_codec())

  use login_request <- web.require_valid_json(login_request)
  use is_user_exists <- web.require_ok(user.find_user_by_email(
    ctx,
    login_request.email,
  ))

  case is_user_exists {
    True -> {
      case user.login_user(ctx, login_request.email, login_request.password) {
        Ok(userid) ->
          json.object([#("success", json.bool(True))])
          |> json.to_string_builder
          |> wisp.json_response(200)
          |> wisp.set_cookie(
            req,
            "traveller.auth",
            userid,
            wisp.Signed,
            60 * 60 * 24,
          )
        Error(e) -> web.error_to_response(e)
      }
    }
    False -> {
      web.error_to_response(error.InvalidLogin)
    }
  }
}
