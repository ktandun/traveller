import database/sql
import gleam/io
import gleam/pgo
import gleam/result
import shared/id.{type Id, type UserId}
import traveller/database
import traveller/error.{type AppError}

pub fn login_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  use pgo.Returned(_, rows) <- result.try(
    sql.check_user_login(conn, email, password) |> database.to_app_error(),
  )

  case rows {
    [sql.CheckUserLoginRow(user_id)] -> Ok(id.to_id(user_id))
    _ -> Error(error.InvalidLogin)
  }
}

pub fn create_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  use query_result <- result.try(
    sql.create_user(conn, email, password) |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "create_user")

  Ok(id.to_id(row.user_id))
}

pub fn find_user_by_email(
  conn: pgo.Connection,
  email: String,
) -> Result(Bool, AppError) {
  use pgo.Returned(rows_count, _) <- result.map(
    sql.find_user_by_email(conn, email) |> database.to_app_error(),
  )

  rows_count == 1
}
