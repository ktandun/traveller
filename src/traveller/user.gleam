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

pub fn create_user(
  ctx: Context,
  email: String,
  password: String,
) -> Result(String, AppError) {
  database.one(
    ctx.db,
    " insert into users 
        ( userid, email, password )
      values
        ( gen_random_uuid(), $1, $2 )
      returning userid
    ",
    [pgo.text(email), pgo.text(password)],
    database.string_decoder(),
  )
}

pub fn is_user_exists(ctx: Context, email: String) -> Result(Bool, AppError) {
  database.one(
    ctx.db,
    " select 1
      from users u
      where u.email = $1
    ",
    [pgo.text(email)],
    database.int_decoder(),
  )
  |> result.map(with: fn(count) { count == 1 })
}
