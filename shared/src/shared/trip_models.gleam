import decode
import gleam/json
import gleam/option.{type Option}

//

pub type UserTrip {
  UserTrip(
    trip_id: String,
    destination: String,
    start_date: String,
    end_date: String,
    places_count: Int,
  )
}

pub fn user_trip_decoder() {
  decode.into({
    use trip_id <- decode.parameter
    use destination <- decode.parameter
    use start_date <- decode.parameter
    use end_date <- decode.parameter
    use places_count <- decode.parameter

    UserTrip(trip_id:, destination:, start_date:, end_date:, places_count:)
  })
  |> decode.field("trip_id", decode.string)
  |> decode.field("destination", decode.string)
  |> decode.field("start_date", decode.string)
  |> decode.field("end_date", decode.string)
  |> decode.field("places_count", decode.int)
}

pub fn user_trip_encoder(data: UserTrip) {
  json.object([
    #("trip_id", json.string(data.trip_id)),
    #("destination", json.string(data.destination)),
    #("start_date", json.string(data.start_date)),
    #("end_date", json.string(data.end_date)),
    #("places_count", json.int(data.places_count)),
  ])
}

pub type UserTrips {
  UserTrips(user_trips: List(UserTrip))
}

pub fn default_user_trips() {
  UserTrips(user_trips: [])
}

pub fn user_trips_decoder() {
  decode.into({
    use user_trips <- decode.parameter
    UserTrips(user_trips:)
  })
  |> decode.field("user_trips", decode.list(user_trip_decoder()))
}

pub fn user_trips_encoder(data: UserTrips) {
  json.object([
    #("user_trips", json.array(from: data.user_trips, of: user_trip_encoder)),
  ])
}

//

pub type UserTripPlace {
  UserTripPlace(
    trip_place_id: String,
    name: String,
    date: String,
    google_maps_link: Option(String),
  )
}

pub type UserTripPlaces {
  UserTripPlaces(
    trip_id: String,
    destination: String,
    start_date: String,
    end_date: String,
    user_trip_places: List(UserTripPlace),
  )
}

pub fn default_user_trip_places() {
  UserTripPlaces(
    trip_id: "",
    destination: "",
    start_date: "",
    end_date: "",
    user_trip_places: [],
  )
}

pub fn user_trip_place_decoder() {
  decode.into({
    use trip_place_id <- decode.parameter
    use name <- decode.parameter
    use date <- decode.parameter
    use google_maps_link <- decode.parameter

    UserTripPlace(trip_place_id:, name:, date:, google_maps_link:)
  })
  |> decode.field("trip_place_id", decode.string)
  |> decode.field("name", decode.string)
  |> decode.field("date", decode.string)
  |> decode.field("google_maps_link", decode.optional(decode.string))
}

pub fn user_trip_place_encoder(data: UserTripPlace) {
  json.object([
    #("trip_place_id", json.string(data.trip_place_id)),
    #("name", json.string(data.name)),
    #("date", json.string(data.date)),
    #("google_maps_link", json.nullable(data.google_maps_link, of: json.string)),
  ])
}

pub fn user_trip_places_decoder() {
  decode.into({
    use trip_id <- decode.parameter
    use destination <- decode.parameter
    use start_date <- decode.parameter
    use end_date <- decode.parameter
    use user_trip_places <- decode.parameter

    UserTripPlaces(
      trip_id:,
      destination:,
      start_date:,
      end_date:,
      user_trip_places:,
    )
  })
  |> decode.field("trip_id", decode.string)
  |> decode.field("destination", decode.string)
  |> decode.field("start_date", decode.string)
  |> decode.field("end_date", decode.string)
  |> decode.field("user_trip_places", decode.list(user_trip_place_decoder()))
}

pub fn user_trip_places_encoder(data: UserTripPlaces) {
  json.object([
    #("trip_id", json.string(data.trip_id)),
    #("destination", json.string(data.destination)),
    #("start_date", json.string(data.start_date)),
    #("end_date", json.string(data.end_date)),
    #(
      "user_trip_places",
      json.array(from: data.user_trip_places, of: user_trip_place_encoder),
    ),
  ])
}

//

pub type CreateTripRequest {
  CreateTripRequest(destination: String, start_date: String, end_date: String)
}

pub fn create_trip_request_decoder() {
  decode.into({
    use destination <- decode.parameter
    use start_date <- decode.parameter
    use end_date <- decode.parameter

    CreateTripRequest(destination:, start_date:, end_date:)
  })
  |> decode.field("destination", decode.string)
  |> decode.field("start_date", decode.string)
  |> decode.field("end_date", decode.string)
}

pub fn create_trip_request_encoder(data: CreateTripRequest) {
  json.object([
    #("destination", json.string(data.destination)),
    #("start_date", json.string(data.start_date)),
    #("end_date", json.string(data.end_date)),
  ])
}
