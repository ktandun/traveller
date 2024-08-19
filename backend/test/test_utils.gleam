import shared/constants
import traveller/database
import traveller/web
import wisp.{type Request}
import wisp/testing
import youid/uuid

pub const testing_user_id = "ab995595-008e-4ab5-94bb-7845f5d48626"

pub const testing_trip_id = "87fccf2c-dbeb-4e6f-b116-5f46463c2ee7"

pub fn gen_uuid() {
  uuid.v4()
}

pub fn with_context(callback: fn(web.Context) -> t) -> t {
  use db <- database.with_connection()

  let context = web.Context(db: db, uuid_provider: gen_uuid)

  callback(context)
}

pub fn set_json_header(req: Request) -> Request {
  req
  |> testing.set_header("content-type", "application/json")
}

pub fn set_auth_cookie(req: Request) -> Request {
  req
  |> testing.set_cookie(constants.cookie, testing_user_id, wisp.Signed)
}
