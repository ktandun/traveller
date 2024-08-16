import gleam/pgo
import gleam/result
import traveller/database
import traveller/error.{type AppError}
import traveller/sql
import traveller/web.{type Context}

pub fn login_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(String, AppError) {
  use pgo.Returned(rows_count, rows) <- result.try(
    sql.get_userid_by_email_password(ctx.db, email, password)
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

pub fn create_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(String, AppError) {
  use pgo.Returned(_, rows) <- result.map(
    sql.create_user(ctx.db, email, password) |> database.map_error(),
  )

  let assert [row] = rows

  row.userid
}

pub fn find_user_by_email(ctx: Context, email: String) -> Result(Bool, AppError) {
  use pgo.Returned(rows_count, _) <- result.map(
    sql.find_user_by_email(ctx.db, email) |> database.map_error(),
  )

  rows_count == 1
}
