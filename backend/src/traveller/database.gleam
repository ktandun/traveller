import gleam/pgo
import gleam/result
import traveller/error

pub fn with_connection(f: fn(pgo.Connection) -> a) -> a {
  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "127.0.0.1",
        port: 5432,
        database: "kenzietandun",
        user: "kenzietandun",
        pool_size: 10,
      ),
    )

  f(db)
}

pub fn map_error(over: Result(a, pgo.QueryError)) {
  result.map_error(over, fn(e) { error.DatabaseError(e) })
}
