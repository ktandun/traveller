import gleam/erlang/process
import mist
import traveller/database
import traveller/router
import traveller/uuid
import traveller/web
import wisp

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  use db <- database.with_connection()

  let context =
    web.Context(db: db, uuid_provider: fn() { uuid.uuiv7() |> uuid.to_string() })

  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    handler
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
