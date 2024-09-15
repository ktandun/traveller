import gleam/bool
import gleam/result
import shared/auth_models.{type LoginRequest, type SignupRequest}
import shared/id.{type Id, type UserId}
import traveller/context.{type Context}
import traveller/database/users_db
import traveller/error.{type AppError}
import youid/uuid

/// Checks if user does not exist yet, creates a user and returns their id
pub fn handle_signup(
  ctx: Context,
  signup_request: SignupRequest,
) -> Result(Id(UserId), AppError) {
  let auth_models.SignupRequest(email, password) = signup_request

  use is_user_exists <- result.try(users_db.find_user_by_email(ctx, email))

  use <- bool.guard(
    is_user_exists,
    Error(error.VerificationFailed("User already exists")),
  )

  users_db.create_user(ctx, email, password)
}

/// Checks if user exists and returns their id
pub fn handle_login(
  ctx: Context,
  login_request: LoginRequest,
) -> Result(String, AppError) {
  let auth_models.LoginRequest(email, password) = login_request
  use is_user_exists <- result.try(users_db.find_user_by_email(ctx, email))

  use <- bool.guard(
    !is_user_exists,
    Error(error.VerificationFailed("User with specified email does not exist")),
  )

  use user_id <- result.try(users_db.login_user(ctx, email, password))

  let session_token = ctx.uuid_provider() |> uuid.to_string

  use _ <- result.try(users_db.set_user_session_token(
    ctx,
    user_id,
    session_token,
  ))

  Ok(session_token)
}

/// Removes user's session token
pub fn handle_logout(ctx: Context, user_id: Id(UserId)) -> Result(Nil, AppError) {
  users_db.remove_user_session_token(ctx, user_id)
}
