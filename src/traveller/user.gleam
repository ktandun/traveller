import gleam/pgo
import traveller/error.{type AppError}
import traveller/sql
import traveller/web.{type Context}

pub fn login_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(String, AppError) {
  case sql.get_userid_by_email_password(ctx.db, email, password) {
    Ok(pgo.Returned(rows_count, rows)) -> {
      case rows_count {
        0 -> Error(error.InvalidLogin)
        _ -> {
          let assert [row] = rows

          Ok(row.userid)
        }
      }
    }
    Error(e) -> Error(error.DatabaseError(e))
  }
}

pub fn create_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(String, AppError) {
  case sql.create_user(ctx.db, email, password) {
    Error(e) -> Error(error.DatabaseError(e))
    Ok(pgo.Returned(_, rows)) -> {
      let assert [row] = rows

      Ok(row.userid)
    }
  }
}

pub fn find_user_by_email(ctx: Context, email: String) -> Result(Bool, AppError) {
  case sql.find_user_by_email(ctx.db, email) {
    Error(e) -> Error(error.DatabaseError(e))
    Ok(pgo.Returned(rows_count, _)) -> {
      Ok(rows_count == 1)
    }
  }
}
