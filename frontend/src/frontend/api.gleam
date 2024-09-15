import env
import frontend/decode_util
import frontend/events.{type AppEvent}
import gleam/dynamic.{type Decoder}
import gleam/http
import gleam/http/request
import gleam/json.{type Json}
import gleam/option.{type Option}
import gleam/result
import gleam/string
import lustre_http.{type HttpError}
import shared/auth_models
import shared/id
import shared/trip_models
import shared/trip_models_codecs
import toy

pub type IncompleteRequest

pub type ReadyToFireRequest

pub type RequestMethod {
  Get
  Post
  Delete
  Put
}

pub opaque type ApiRequest(ready, decoder, app_event) {
  ApiRequest(
    url: String,
    method: RequestMethod,
    json: Option(Json),
    response_decoder: Option(Decoder(decoder)),
    to_msg: fn(Result(decoder, HttpError)) -> app_event,
    to_nil_msg: fn(Result(Nil, HttpError)) -> app_event,
  )
}

pub fn new_request() -> ApiRequest(IncompleteRequest, decoder, AppEvent) {
  ApiRequest(
    url: "",
    method: Get,
    json: option.None,
    response_decoder: option.None,
    to_msg: fn(_) { events.NoEvent },
    to_nil_msg: fn(_) { events.NoEvent },
  )
}

pub fn with_url(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
  url: String,
) {
  ApiRequest(..api_request, url: env.api_base_url <> url)
}

pub fn with_method(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
  method: RequestMethod,
) {
  ApiRequest(..api_request, method:)
}

pub fn with_json_body(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
  json: Json,
) {
  ApiRequest(..api_request, json: option.Some(json))
}

pub fn with_response_decoder(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
  response_decoder: Decoder(decoder),
) {
  ApiRequest(..api_request, response_decoder: option.Some(response_decoder))
}

pub fn with_to_event(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
  to_msg: fn(Result(decoder, HttpError)) -> app_event,
) {
  ApiRequest(..api_request, to_msg:)
}

pub fn with_ignore_response_to_event(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
  to_nil_msg: fn(Result(Nil, HttpError)) -> app_event,
) {
  ApiRequest(..api_request, to_nil_msg:)
}

pub fn build(
  api_request: ApiRequest(IncompleteRequest, decoder, app_event),
) -> ApiRequest(ReadyToFireRequest, decoder, app_event) {
  // validate request here

  let assert True =
    string.starts_with(api_request.url, "http://")
    || string.starts_with(api_request.url, "https://")

  ApiRequest(
    url: api_request.url,
    method: api_request.method,
    json: api_request.json,
    response_decoder: api_request.response_decoder,
    to_msg: api_request.to_msg,
    to_nil_msg: api_request.to_nil_msg,
  )
}

pub fn send(api_request: ApiRequest(ReadyToFireRequest, decoder, app_event)) {
  let req =
    request.to(api_request.url)
    |> result.unwrap(request.new())

  let req = case api_request.json {
    option.Some(json) ->
      req
      |> request.set_header("Content-Type", "application/json")
      |> request.set_body(json.to_string(json))
    _ -> req
  }

  let method = case api_request.method {
    Get -> http.Get
    Put -> http.Put
    Delete -> http.Delete
    Post -> http.Post
  }

  case api_request.response_decoder {
    option.Some(decoder) ->
      req
      |> request.set_method(method)
      |> lustre_http.send(lustre_http.expect_json(decoder, api_request.to_msg))
    _ ->
      req
      |> request.set_method(method)
      |> lustre_http.send(lustre_http.expect_anything(api_request.to_nil_msg))
  }
}

// ---------------------------------
// --------- API REQUESTS ----------
// ---------------------------------

pub fn send_signup_request(signup_request: auth_models.SignupRequest) {
  new_request()
  |> with_url("/api/signup")
  |> with_method(Post)
  |> with_json_body(auth_models.signup_request_encoder(signup_request))
  |> with_ignore_response_to_event(fn(result) {
    events.SignupPage(events.SignupPageApiReturnedResponse(result))
  })
  |> build
  |> send
}

pub fn send_logout_request() {
  new_request()
  |> with_url("/api/logout")
  |> with_method(Post)
  |> with_ignore_response_to_event(fn(result) {
    case result {
      Ok(_) -> events.LogoutApiReturnedResponse
      Error(_) -> events.NoEvent
    }
  })
  |> build
  |> send
}

pub fn send_login_request(login_request: auth_models.LoginRequest) {
  new_request()
  |> with_url("/api/login")
  |> with_method(Post)
  |> with_json_body(auth_models.login_request_encoder(login_request))
  |> with_ignore_response_to_event(fn(result) {
    events.LoginPage(events.LoginPageApiReturnedResponse(result))
  })
  |> build
  |> send
}

pub fn send_update_trip_companions_request(
  trip_id: String,
  update_request: trip_models.UpdateTripCompanionsRequest,
) {
  new_request()
  |> with_url("/api/trips/" <> trip_id <> "/companions")
  |> with_method(Post)
  |> with_json_body(trip_models.update_trip_companions_request_encoder(
    update_request,
  ))
  |> with_ignore_response_to_event(fn(decode_result) {
    events.TripCompanionsPage(events.TripCompanionsPageApiReturnedResponse(
      trip_id,
      decode_result,
    ))
  })
  |> build
  |> send
}

pub fn send_get_trip_details_request(trip_id: String) {
  new_request()
  |> with_url("/api/trips/" <> trip_id <> "/places")
  |> with_method(Get)
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(trip_models.user_trip_places_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripDetailsPage(events.TripDetailsPageApiReturnedTripDetails(result))
  })
  |> build
  |> send
}

pub fn send_get_user_trips_request() {
  new_request()
  |> with_url("/api/trips/")
  |> with_method(Get)
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(trip_models.user_trips_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripsDashboardPage(events.TripsDashboardPageApiReturnedTrips(result))
  })
  |> build
  |> send
}

pub fn send_create_trip_request(create_request: trip_models.CreateTripRequest) {
  new_request()
  |> with_url("/api/trips/")
  |> with_method(Post)
  |> with_json_body(trip_models.create_trip_request_encoder(create_request))
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(id.id_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripCreatePage(events.TripCreatePageApiReturnedResponse(result))
  })
  |> build
  |> send
}

pub fn send_upsert_trip_place_request(
  trip_id: String,
  trip_place_id: Option(String),
  create_request: trip_models.CreateTripPlaceRequest,
) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> option.unwrap(trip_place_id, ""),
  )
  |> with_method(case trip_place_id {
    option.Some(_) -> Put
    option.None -> Post
  })
  |> with_json_body(trip_models.create_trip_place_request_encoder(
    create_request,
  ))
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(id.id_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(decode_result) {
    case trip_place_id {
      option.Some(_) ->
        events.TripPlaceUpdatePage(
          events.TripPlaceUpdatePageApiReturnedResponse(trip_id, decode_result),
        )

      option.None ->
        events.TripPlaceCreatePage(
          events.TripPlaceCreatePageApiReturnedResponse(trip_id, decode_result),
        )
    }
  })
  |> build
  |> send
}

pub fn send_trip_update_request(
  trip_id: String,
  update_request: trip_models.UpdateTripRequest,
) {
  new_request()
  |> with_url("/api/trips/" <> trip_id)
  |> with_method(Put)
  |> with_json_body(trip_models.update_trip_request_encoder(update_request))
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(id.id_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripUpdatePage(events.TripUpdatePageApiReturnedResponse(result))
  })
  |> build
  |> send
}

pub fn send_get_place_activities_request(trip_id: String, trip_place_id: String) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> trip_place_id <> "/activities",
  )
  |> with_method(Get)
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(trip_models_codecs.place_activities_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripPlaceActivitiesPage(
      events.TripPlaceActivitiesPageApiReturnedActivities(result),
    )
  })
  |> build
  |> send
}

pub fn send_place_activities_update_request(
  trip_id: String,
  trip_place_id: String,
  update_request: trip_models.PlaceActivities,
) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> trip_place_id <> "/activities",
  )
  |> with_method(Put)
  |> with_json_body(
    update_request |> trip_models_codecs.place_activities_encoder,
  )
  |> with_ignore_response_to_event(fn(response) {
    events.TripPlaceActivitiesPage(
      events.TripPlaceActivitiesPageApiReturnedSaveResponse(response),
    )
  })
  |> build
  |> send
}

pub fn send_get_place_accomodation_request(
  trip_id: String,
  trip_place_id: String,
) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> trip_place_id <> "/accomodations",
  )
  |> with_method(Get)
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(trip_models_codecs.place_accomodation_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripPlaceAccomodationPage(
      events.TripPlaceAccomodationPageApiReturnedAccomodation(result),
    )
  })
  |> build
  |> send
}

pub fn send_place_accomodation_update_request(
  trip_id: String,
  trip_place_id: String,
  update_request: trip_models.PlaceAccomodation,
) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> trip_place_id <> "/accomodations",
  )
  |> with_method(Put)
  |> with_json_body(trip_models_codecs.place_accomodation_encoder(
    update_request,
  ))
  |> with_ignore_response_to_event(fn(decode_result) {
    events.TripPlaceAccomodationPage(
      events.TripPlaceAccomodationPageApiReturnedSaveResponse(decode_result),
    )
  })
  |> build
  |> send
}

pub fn send_get_place_culinaries_request(trip_id: String, trip_place_id: String) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> trip_place_id <> "/culinaries",
  )
  |> with_method(Get)
  |> with_response_decoder(fn(response) {
    response
    |> toy.decode(trip_models_codecs.trip_place_culinaries_decoder())
    |> decode_util.map_toy_error_to_decode_errors()
  })
  |> with_to_event(fn(result) {
    events.TripPlaceCulinariesPage(
      events.TripPlaceCulinariesPageApiReturnedCulinaries(result),
    )
  })
  |> build
  |> send
}

pub fn send_place_culinaries_update_request(
  trip_id: String,
  trip_place_id: String,
  update_request: trip_models.PlaceCulinaries,
) {
  new_request()
  |> with_url(
    "/api/trips/" <> trip_id <> "/places/" <> trip_place_id <> "/culinaries",
  )
  |> with_method(Put)
  |> with_json_body(
    update_request |> trip_models_codecs.trip_place_culinaries_encoder,
  )
  |> with_ignore_response_to_event(fn(response) {
    events.TripPlaceCulinariesPage(
      events.TripPlaceCulinariesPageApiReturnedSaveResponse(response),
    )
  })
  |> build
  |> send
}
