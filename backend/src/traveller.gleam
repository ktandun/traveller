import gleam/erlang/process
import gleam/io
import mist
import setup
import traveller/database
import traveller/router
import traveller/web
import wisp
import wisp/wisp_mist
import youid/uuid

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  use db <- database.with_connection()

  setup.radiate()

  let context = web.Context(db: db, uuid_provider: uuid.v7)

  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  io.debug("Running")

  process.sleep_forever()
}
