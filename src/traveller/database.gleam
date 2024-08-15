import gleam/pgo

pub fn with_connection(f: fn(pgo.Connection) -> a) -> a {
  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "127.0.0.1",
        port: 5432,
        database: "kenzietandun",
        user: "kenzietandun",
      ),
    )

  f(db)
}
