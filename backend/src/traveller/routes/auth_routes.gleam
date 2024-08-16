import gleam/bool
import gleam/http.{Post}
import gleam/json
import gleam/pgo
import gleam/result
import shared/auth
import shared/constants
import traveller/database
import traveller/error.{type AppError}
import traveller/json_util
import traveller/sql
import traveller/web.{type Context}
import wisp.{type Request, type Response}

// Public functions ------------------------------------------

pub fn signup(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)

  let response = {
    use signup_request <- result.try(json_util.try_decode(
      json,
      auth.signup_request_codec(),
    ))

    use is_user_exists <- result.try(find_user_by_email(
      ctx.db,
      signup_request.email,
    ))

    use <- bool.guard(is_user_exists, Error(error.UserAlreadyRegistered))

    create_user(ctx.db, signup_request.email, signup_request.password)
  }

  case response {
    Ok(user_id) ->
      json.object([#("user_id", json.string(user_id))])
      |> json.to_string_builder
      |> wisp.json_response(200)
    Error(e) -> web.error_to_response(e)
  }
}

pub fn login(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)

  let response = {
    use login_request <- result.try(json_util.try_decode(
      json,
      auth.login_request_codec(),
    ))

    use is_user_exists <- result.try(find_user_by_email(
      ctx.db,
      login_request.email,
    ))

    use <- bool.guard(!is_user_exists, Error(error.InvalidLogin))

    login_user(ctx.db, login_request.email, login_request.password)
  }

  case response {
    Ok(userid) ->
      json.object([#("success", json.bool(True))])
      |> json.to_string_builder
      |> wisp.json_response(200)
      |> wisp.set_cookie(
        req,
        constants.cookie,
        userid,
        wisp.Signed,
        60 * 60 * 24,
      )
    Error(e) -> web.error_to_response(e)
  }
}

// Private functions -----------------------------------------

fn login_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(String, AppError) {
  use pgo.Returned(rows_count, rows) <- result.try(
    sql.get_userid_by_email_password(conn, email, password)
    |> database.map_error(),
  )

  case rows_count {
    0 -> Error(error.InvalidLogin)
    _ -> {
      let assert [row] = rows

      Ok(row.userid)
    }
  }
}

fn create_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(String, AppError) {
  use pgo.Returned(_, rows) <- result.map(
    sql.create_user(conn, email, password) |> database.map_error(),
  )

  let assert [row] = rows

  row.userid
}

fn find_user_by_email(
  conn: pgo.Connection,
  email: String,
) -> Result(Bool, AppError) {
  use pgo.Returned(rows_count, _) <- result.map(
    sql.find_user_by_email(conn, email) |> database.map_error(),
  )

  rows_count == 1
}
