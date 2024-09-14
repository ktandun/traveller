import shared/constants
import shared/id
import traveller/context.{type Context, Context}
import traveller/database
import traveller/database/users_db
import wisp.{type Request}
import wisp/testing
import youid/uuid

pub const testing_user_id = "ab995595-008e-4ab5-94bb-7845f5d48626"

pub const testing_user_session_token = "fb9d5701-f1e1-4b86-8dfd-f51722677ced"

pub const testing_trip_id = "87fccf2c-dbeb-4e6f-b116-5f46463c2ee7"

pub const testing_trip_place_id = "619ee043-d377-4ef7-8134-dc16c3c4af99"

pub const testing_trip_place_id_without_accomodation = "a99f7893-632a-41fb-bd40-2f8fe8dd1d7e"

pub const testing_place_activity_id = "c26a0603-16d2-4156-b985-acf398b16cd2"

pub fn gen_uuid() {
  uuid.v4()
}

pub fn with_context(callback: fn(Context) -> t) -> t {
  use db <- database.with_connection()

  let context =
    Context(db: db, uuid_provider: gen_uuid, static_directory: "/priv/static")

  callback(context)
}

pub fn set_json_header(req: Request) -> Request {
  req
  |> testing.set_header("content-type", "application/json")
}

pub fn set_auth_cookie(req: Request) -> Request {
  req
  |> testing.set_cookie(
    constants.cookie,
    testing_user_session_token,
    wisp.Signed,
  )
}

pub fn reset_testing_user_session_token() {
  use ctx <- with_context()

  users_db.set_user_session_token(
    ctx,
    testing_user_id |> id.to_id,
    testing_user_session_token,
  )
}
