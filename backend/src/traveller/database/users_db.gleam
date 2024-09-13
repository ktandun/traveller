import gleam/dynamic
import gleam/pgo
import gleam/result
import shared/id.{type Id, type UserId}
import traveller/context.{type Context}
import traveller/database
import traveller/error.{type AppError}

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

pub fn find_user_by_user_id(
  ctx: Context,
  user_id: String,
) -> Result(Bool, AppError) {
  let sql =
    "SELECT
        count(1)
    FROM
        users
    WHERE
        user_id = $1::uuid
    "

  let return_type = dynamic.element(0, dynamic.int)

  use pgo.Returned(row_count, _) <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(user_id)], return_type)
    |> database.to_app_error(),
  )

  Ok(row_count == 1)
}
