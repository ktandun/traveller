import gleam/erlang/os
import gleam/erlang/process
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

  let secret_key_base =
    "ygWvbPGgX8iBS8zw13UQdmxTkM5Ri9igaPB8wDSg8XuHqb569bAcdQFcEn1Hitjb"

  use db <- database.with_connection()

  let assert Ok(deploy_env) = os.get_env("DEPLOY_ENV")

  case deploy_env {
    "Production" -> {
      Nil
    }
    _ -> {
      setup.radiate()
    }
  }

  let context =
    web.Context(
      db: db,
      uuid_provider: uuid.v7,
      static_directory: static_directory(),
    )

  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

pub fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(priv_directory) = wisp.priv_directory("traveller")
  priv_directory <> "/static"
}
