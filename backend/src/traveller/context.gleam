import gleam/pgo
import youid/uuid.{type Uuid}

pub type Context {
  Context(
    db: pgo.Connection,
    uuid_provider: fn() -> Uuid,
    static_directory: String,
  )
}

pub fn with_db_conn(ctx: Context, db_conn: pgo.Connection) {
  Context(..ctx, db: db_conn)
}
