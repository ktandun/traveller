import gleam/bool
import gleam/http.{Post}
import gleam/io
import gleam/json
import gleam/pgo
import gleam/result
import shared/auth
import shared/constants
import shared/id.{type Id, type UserId}
import traveller/database
import traveller/error.{type AppError}
import traveller/json_util
import traveller/sql
import traveller/web.{type Context}
import wisp.{type Request, type Response}
import youid/uuid

// Public functions ------------------------------------------

pub fn handle_signup(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)

  let response = {
    use signup_request <- result.try(json_util.try_decode(
      json,
      auth.signup_request_decoder(),
    ))

    let auth.SignupRequest(email, password) = signup_request

    use is_user_exists <- result.try(find_user_by_email(
      ctx.db,
      signup_request.email,
    ))

    use <- bool.guard(is_user_exists, Error(error.UserAlreadyRegistered))

    create_user(ctx.db, email, password)
  }

  use user_id <- web.require_ok(response)

  user_id
  |> id.id_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
}

pub fn handle_login(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)

  let response = {
    use login_request <- result.try(json_util.try_decode(
      json,
      auth.login_request_decoder(),
    ))

    let auth.LoginRequest(email, password) = login_request

    use is_user_exists <- result.try(find_user_by_email(
      ctx.db,
      login_request.email,
    ))

    use <- bool.guard(!is_user_exists, Error(error.InvalidLogin))

    login_user(ctx.db, email, password)
  }

  use user_id <- web.require_ok(response)

  user_id
  |> id.id_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
  |> wisp.set_cookie(
    req,
    constants.cookie,
    uuid.to_string(id.id_value(user_id)),
    wisp.Signed,
    60 * 60 * 24,
  )
}

// Private functions -----------------------------------------

fn login_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  use pgo.Returned(rows_count, rows) <- result.try(
    sql.get_userid_by_email_password(conn, email, password)
    |> database.map_error(),
  )

  case rows_count {
    0 -> Error(error.InvalidLogin)
    _ -> {
      let assert [row] = rows

      Ok(id.to_id_from_uuid(row.user_id))
    }
  }
}

fn create_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  use pgo.Returned(_, rows) <- result.map(
    sql.create_user(conn, email, password) |> database.map_error(),
  )

  let assert [row] = rows

  id.to_id_from_uuid(row.user_id)
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
