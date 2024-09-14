import gleam/dynamic
import gleam/option.{type Option}
import gleam/pgo
import gleam/result
import shared/id.{type Id, type UserId}
import traveller/context.{type Context}
import traveller/database
import traveller/error.{type AppError}

pub fn set_user_session_token(
  ctx: Context,
  user_id: Id(UserId),
  session_token: String,
) -> Result(Nil, AppError) {
  let sql =
    "
    UPDATE 
        users 
    SET 
        session_token = $2, 
        login_timestamp = timezone('utc', now())
    WHERE 
        user_id = $1;
    "

  let return_type = dynamic.dynamic

  pgo.execute(
    sql,
    ctx.db,
    [pgo.text(user_id |> id.id_value), pgo.text(session_token)],
    return_type,
  )
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn login_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  let sql =
    "
    SELECT check_user_login ($1, $2);
    "

  let return_type = dynamic.element(0, dynamic.string)

  use query_result <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(email), pgo.text(password)], return_type)
    |> database.to_app_error(),
  )

  use user_id <- database.require_single_row(query_result, "login_user")

  Ok(id.to_id(user_id))
}

pub fn create_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  let sql =
    "
    INSERT INTO users (user_id, email, PASSWORD)
        VALUES (gen_random_uuid (), $1, crypt($2, gen_salt('bf', 8)))
    RETURNING
        user_id::TEXT
    "

  let return_type = dynamic.element(0, dynamic.string)

  use query_result <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(email), pgo.text(password)], return_type)
    |> database.to_app_error(),
  )

  use user_id <- database.require_single_row(query_result, "create_user")

  Ok(id.to_id(user_id))
}

pub fn find_user_by_email(ctx: Context, email: String) -> Result(Bool, AppError) {
  let sql =
    "
    SELECT
        1
    FROM
        users
    WHERE
        email = $1
    "

  let return_type = dynamic.dynamic

  use pgo.Returned(rows_count, _) <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(email)], return_type)
    |> database.to_app_error(),
  )

  Ok(rows_count == 1)
}

pub fn find_user_by_session_token(
  ctx: Context,
  session_token: String,
) -> Result(Option(Id(UserId)), AppError) {
  let sql =
    "
    SELECT
        coalesce(max(user_id::text), null)
    FROM
        users
    WHERE
        session_token = $1::uuid
    "

  let return_type = dynamic.element(0, dynamic.optional(of: dynamic.string))

  use pgo.Returned(_, rows) <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(session_token)], return_type)
    |> database.to_app_error(),
  )

  case rows {
    [user_id] -> {
      Ok(user_id |> option.map(id.to_id))
    }
    _ ->
      Error(error.VerificationFailed(
        "Unable to retrieve session token from database",
      ))
  }
}
