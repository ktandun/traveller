import gleam/pgo
import gleam/result
import traveller/error.{type AppError}

pub fn with_connection(f: fn(pgo.Connection) -> a) -> a {
  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "127.0.0.1",
        port: 5432,
        database: "kenzietandun",
        user: "kenzietandun",
        pool_size: 2,
      ),
    )

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

