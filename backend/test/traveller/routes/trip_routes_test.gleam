import birl
import gleam/io
import gleam/list
import gleam/option
import gleeunit/should
import shared/id
import shared/trip_models
import shared/trip_models_codecs
import test_utils
import traveller/json_util
import traveller/router
import wisp/testing
import youid/uuid

pub fn trips_unauthorised_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/api/trips", [])
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn get_user_trips_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/api/trips", [])
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(
      testing.string_body(response),
      trip_models.user_trips_decoder(),
    )

  should.be_ok(response)

  let assert Ok(_user_trips) = response
}

pub fn create_user_trips_test() {
  use ctx <- test_utils.with_context()

  let json =
    trip_models.CreateTripRequest(
      destination: "India " <> test_utils.gen_uuid() |> uuid.to_string(),
      start_date: birl.Day(2024, 01, 01),
      end_date: birl.Day(2025, 01, 01),
    )
    |> trip_models.create_trip_request_encoder

  let response =
    testing.post_json("/api/trips", [], json)
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
    trip_models.CreateTripRequest(
      destination: "India " <> test_utils.gen_uuid() |> uuid.to_string(),
      start_date: birl.Day(2024, 01, 01),
      end_date: birl.Day(2025, 01, 01),
    )
    |> trip_models.create_trip_request_encoder

  let response =
    testing.post_json("/api/trips", [], json)
    |> test_utils.set_json_header
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn get_user_trip_places_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get("/api/trips/" <> test_utils.testing_trip_id <> "/places", [])
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(
      testing.string_body(response),
      trip_models.user_trip_places_decoder(),
    )

  should.be_ok(response)

  let assert Ok(_response) = response
}

pub fn get_user_trip_places_with_invalid_trip_id_test() {
  use ctx <- test_utils.with_context()

  ["514acc18-c3cc-4abe-8bca-0df710c2553b", "heyyyyyyyyyyyyyyyyyyyyyyyyyyyy"]
  |> list.each(fn(id) {
    let response =
      testing.get("/api/trips/" <> id <> "/places", [])
      |> test_utils.set_auth_cookie
      |> router.handle_request(ctx)

    response.status
    |> should.equal(400)
  })
}

pub fn get_place_activities_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get(
      "/api/trips/"
        <> test_utils.testing_trip_id
        <> "/places/"
        <> test_utils.testing_trip_place_id
        <> "/activities",
      [],
    )
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  response.status
  |> should.equal(200)
}

pub fn get_place_activities_no_results_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.get(
      "/api/trips/"
        <> test_utils.testing_trip_id
        <> "/places/"
        <> "65916ea8-c637-4921-89a0-97d3661ce782"
        <> "/activities",
      [],
    )
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  response.status
  |> should.equal(200)
}

pub fn create_place_activity_test() {
  use ctx <- test_utils.with_context()

  let json =
    trip_models.PlaceActivities(
      trip_id: test_utils.testing_trip_id,
      trip_place_id: test_utils.testing_trip_place_id,
      place_name: "Hello",
      place_activities: [
        trip_models.PlaceActivity(
          place_activity_id: test_utils.testing_place_activity_id,
          name: "Test",
          information_url: option.Some("https://www.google.com"),
          start_time: option.Some("11:00"),
          end_time: option.Some("15:00"),
          entry_fee: option.Some(3.0),
        ),
      ],
    )
    |> trip_models_codecs.place_activities_encoder

  let response =
    testing.put_json(
      "/api/trips/"
        <> test_utils.testing_trip_id
        <> "/places/"
        <> test_utils.testing_trip_place_id
        <> "/activities",
      [],
      json,
    )
    |> test_utils.set_json_header
    |> test_utils.set_auth_cookie
    |> router.handle_request(ctx)

  response.status
  |> should.equal(200)
}
