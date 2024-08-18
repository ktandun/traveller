import gleam/io
import gleeunit
import gleeunit/should
import shared/auth
import shared/id
import shared/trips
import test_utils
import traveller/json_util
import traveller/router
import wisp/testing

pub fn main() {
  gleeunit.main()
}

pub fn signup_successful_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth.SignupRequest(
      email: test_utils.gen_uuid() <> "@example.com",
      password: "password",
    )
    |> auth.signup_request_encoder()

  let response =
    testing.post_json("/signup", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}

pub fn signup_invalid_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth.SignupRequest(email: "test@example.com", password: "password")
    |> auth.signup_request_encoder()

  let response =
    testing.post_json("/signup", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_error(response)
}

pub fn login_successful_test() {
  use ctx <- test_utils.with_context()

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
  use ctx <- test_utils.with_context()

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
  use ctx <- test_utils.with_context()

  let response =
    testing.post("/login", [], "{hey}")
    |> test_utils.set_json_header
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}

pub fn trips_unauthorised_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/trips", [])
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn get_user_trips_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/trips", [])
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(
      testing.string_body(response),
      trips.user_trips_decoder(),
    )

  should.be_ok(response)

  let assert Ok(user_trips) = response
}

pub fn create_user_trips_test() {
  use ctx <- test_utils.with_context()

  let json =
    trips.CreateTripRequest(destination: "India " <> test_utils.gen_uuid())
    |> trips.create_trip_request_encoder

  let response =
    testing.post_json("/trips", [], json)
    |> test_utils.set_json_header
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}

pub fn get_user_trip_places_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/trips/87fccf2c-dbeb-4e6f-b116-5f46463c2ee7/places", [])
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(
      testing.string_body(response),
      trips.user_trip_places_decoder(),
    )

  should.be_ok(response)

  let assert Ok(response) = response

  io.debug(response)
}
