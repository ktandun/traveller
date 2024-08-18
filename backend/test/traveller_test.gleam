import gleam/io
import youid/uuid
import gleam/result
import gleeunit
import gleeunit/should
import shared/auth
import shared/constants
import shared/id.{type Id}
import shared/trips
import traveller/database
import traveller/json_util
import traveller/router
import traveller/web
import wisp
import wisp/testing

const testing_user_id = "ab995595-008e-4ab5-94bb-7845f5d48626"

pub fn main() {
  gleeunit.main()
}

fn with_context(callback: fn(web.Context) -> t) -> t {
  use db <- database.with_connection()

  let context = web.Context(db: db, uuid_provider: fn() { uuid.v4() |> uuid.to_string() })

  callback(context)
}

pub fn login_successful_test() {
  use ctx <- with_context()

  let json =
    auth.LoginRequest(email: "test@example.com", password: "password")
    |> auth.login_request_encoder

  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}

pub fn login_invalid_login_test() {
  use ctx <- with_context()

  let json =
    auth.LoginRequest(email: "test@example.com", password: "")
    |> auth.login_request_encoder

  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}

pub fn login_invalid_json_test() {
  use ctx <- with_context()

  let response =
    testing.post("/login", [], "{hey}")
    |> testing.set_header("content-type", "application/json")
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}

pub fn trips_unauthorised_test() {
  use ctx <- with_context()

  let response =
    testing.get("/trips", [])
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn get_user_trips_test() {
  use ctx <- with_context()

  let response =
    testing.get("/trips", [])
    |> testing.set_cookie(constants.cookie, testing_user_id, wisp.Signed)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), trips.user_trips_decoder())

  should.be_ok(response)
}

pub fn create_user_trips_test() {
  use ctx <- with_context()

  let json =
    trips.CreateTripRequest(destination: "India")
    |> trips.create_trip_request_encoder

  let response =
    testing.post_json("/trips", [], json)
    |> testing.set_header("content-type", "application/json")
    |> testing.set_cookie(constants.cookie, testing_user_id, wisp.Signed)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}
