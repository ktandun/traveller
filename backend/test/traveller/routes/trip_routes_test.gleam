import gleeunit/should
import shared/id
import shared/trips
import test_utils
import traveller/json_util
import traveller/router
import wisp/testing
import youid/uuid

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

  let assert Ok(_user_trips) = response
}

pub fn create_user_trips_test() {
  use ctx <- test_utils.with_context()

  let json =
    trips.CreateTripRequest(
      destination: "India " <> test_utils.gen_uuid() |> uuid.to_string(),
    )
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

pub fn create_user_trips_unauthenticated_test() {
  use ctx <- test_utils.with_context()

  let json =
    trips.CreateTripRequest(
      destination: "India " <> test_utils.gen_uuid() |> uuid.to_string(),
    )
    |> trips.create_trip_request_encoder

  let response =
    testing.post_json("/trips", [], json)
    |> test_utils.set_json_header
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn get_user_trip_places_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/trips/" <> test_utils.testing_trip_id <> "/places", [])
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(
      testing.string_body(response),
      trips.user_trip_places_decoder(),
    )

  should.be_ok(response)

  let assert Ok(_response) = response
}

pub fn get_user_trip_places_with_invalid_trip_test() {
  use ctx <- test_utils.with_context()

  let random_uuid = "514acc18-c3cc-4abe-8bca-0df710c2553b"

  let response =
    testing.get("/trips/" <> random_uuid <> "/places", [])
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}
