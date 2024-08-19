import gleam/erlang/process
import mist
import traveller/database
import traveller/router
import traveller/web
import wisp
import youid/uuid

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = wisp.random_string(64)

  use db <- database.with_connection()

  let context = web.Context(db: db, uuid_provider: uuid.v7)

  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    handler
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}
