import gleam/pgo
import gleam/result
import traveller/database
import traveller/error.{type AppError}
import traveller/web.{type Context}

pub fn login_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(Bool, AppError) {
  database.one(
    ctx.db,
    " select count(1) from users u where u.email = $1 and u.password = $2 ",
    [pgo.text(email), pgo.text(password)],
    database.int_decoder(),
  )
  |> result.map(with: fn(count) { count == 1 })
}
