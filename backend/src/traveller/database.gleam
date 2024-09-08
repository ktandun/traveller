import gleam/erlang/os
import gleam/int
import gleam/option
import gleam/pgo
import gleam/result
import traveller/error.{type AppError}

pub fn with_connection(f: fn(pgo.Connection) -> a) -> a {
  let assert Ok(db_host) = os.get_env("DATABASE_HOST")
  let assert Ok(db_port) = os.get_env("DATABASE_PORT")
  let assert Ok(db_port) = db_port |> int.parse
  let assert Ok(db_user) = os.get_env("DATABASE_USER")
  let assert Ok(db_pass) = os.get_env("DATABASE_PASS")
  let assert Ok(db_db) = os.get_env("DATABASE_DB")

  let config =
    pgo.Config(
      ..pgo.default_config(),
      host: db_host,
      port: db_port,
      database: db_db,
      user: db_user,
      password: option.Some(db_pass),
      pool_size: 2,
    )

  let db = pgo.connect(config)

  f(db)
}

pub fn to_app_error(over: Result(a, pgo.QueryError)) {
  result.map_error(over, fn(e) { error.DatabaseError(e) })
}

pub fn require_single_row(
  result: pgo.Returned(a),
  error_desc: String,
  f: fn(a) -> Result(b, AppError),
) {
  let pgo.Returned(_, rows) = result

  case rows {
    [row] -> {
      f(row)
    }
    _ -> Error(error.QueryNotReturningSingleResult(error_desc))
  }
}
