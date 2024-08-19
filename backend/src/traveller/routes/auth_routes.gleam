import gleam/bool
import gleam/result
import shared/auth.{type LoginRequest, type SignupRequest}
import shared/id.{type Id, type UserId}
import traveller/database/users_db
import traveller/error.{type AppError}
import traveller/web.{type Context}

/// Checks if user does not exist yet, creates a user and returns their id
pub fn handle_signup(
  ctx: Context,
  signup_request: SignupRequest,
) -> Result(Id(UserId), AppError) {
  let auth.SignupRequest(email, password) = signup_request

  use is_user_exists <- result.try(users_db.find_user_by_email(ctx.db, email))

  use <- bool.guard(is_user_exists, Error(error.UserAlreadyRegistered))

  users_db.create_user(ctx.db, email, password)
}

/// Checks if user exists and returns their id
pub fn handle_login(
  ctx: Context,
  login_request: LoginRequest,
) -> Result(Id(UserId), AppError) {
  let auth.LoginRequest(email, password) = login_request
  use is_user_exists <- result.try(users_db.find_user_by_email(ctx.db, email))

  use <- bool.guard(!is_user_exists, Error(error.InvalidLogin))

  users_db.login_user(ctx.db, email, password)
}
