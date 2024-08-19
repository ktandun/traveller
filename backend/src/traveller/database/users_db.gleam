import gleam/pgo
import gleam/result
import shared/id.{type Id, type UserId}
import traveller/database
import traveller/error.{type AppError}
import traveller/sql

pub fn login_user(
  conn: pgo.Connection,
  email: String,
  password: String,
) -> Result(Id(UserId), AppError) {
  use query_result <- result.try(
    sql.get_userid_by_email_password(conn, email, password)
    |> database.to_app_error(),
  )

  let pgo.Returned(rows_count, _rows) = query_result

  case rows_count {
    0 -> Error(error.InvalidLogin)
    _ -> {
      use row <- database.require_single_row(query_result, "create_user")

      Ok(id.to_id_from_uuid(row.user_id))
    }
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

  Ok(id.to_id_from_uuid(row.user_id))
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
