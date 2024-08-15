import gleam/dynamic
import gleam/io
import gleam/pgo
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
      ),
    )

  f(db)
}

pub fn one(
  db: pgo.Connection,
  sql: String,
  arguments: List(pgo.Value),
  decoder: dynamic.Decoder(t),
) -> Result(t, AppError) {
  case pgo.execute(sql, db, arguments, decoder) {
    Ok(result) -> {
      let assert [row] = result.rows
      Ok(row)
    }
    Error(e) -> {
      e |> io.debug
      Error(error.DatabaseError)
    }
  }
}

pub fn int_decoder() {
  dynamic.element(0, dynamic.int)
}
