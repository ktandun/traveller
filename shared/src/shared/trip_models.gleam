import birl
import gleam/json
import gleam/option.{type Option}
import gleam/string
import shared/custom_decoders
import shared/custom_encoders
import toy

const default_day = birl.Day(1, 1, 1)

//

pub type UserTrip {
  UserTrip(
    trip_id: String,
    destination: String,
    start_date: birl.Day,
    end_date: birl.Day,
    places_count: Int,
  )
}

pub fn user_trip_decoder() {
  use trip_id <- toy.field("trip_id", custom_decoders.uuid_decoder("trip_id"))
  use destination <- toy.field("destination", toy.string)
  use start_date <- toy.field(
    "start_date",
    custom_decoders.day_decoder("start_date"),
  )
  use end_date <- toy.field("end_date", custom_decoders.day_decoder("end_date"))
  use places_count <- toy.field("places_count", toy.int)

  toy.decoded(UserTrip(
    trip_id:,
    destination:,
    start_date:,
    end_date:,
    places_count:,
  ))
}

pub fn user_trip_encoder(data: UserTrip) {
  json.object([
    #("trip_id", json.string(data.trip_id |> string.lowercase)),
    #("destination", json.string(data.destination)),
    #(
      "start_date",
      json.string(data.start_date |> custom_encoders.day_to_string),
    ),
    #("end_date", json.string(data.end_date |> custom_encoders.day_to_string)),
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
  use user_trips <- toy.field("user_trips", toy.list(user_trip_decoder()))

  toy.decoded(UserTrips(user_trips:))
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
    date: birl.Day,
    google_maps_link: Option(String),
  )
}

pub type UserTripPlaces {
  UserTripPlaces(
    trip_id: String,
    destination: String,
    start_date: birl.Day,
    end_date: birl.Day,
    user_trip_places: List(UserTripPlace),
    user_trip_companions: List(UserTripCompanion),
  )
}

pub fn default_user_trip_places() {
  UserTripPlaces(
    trip_id: "",
    destination: "",
    start_date: default_day,
    end_date: default_day,
    user_trip_places: [],
    user_trip_companions: [],
  )
}

pub fn user_trip_place_decoder() {
  use trip_place_id <- toy.field("trip_place_id", toy.string)
  use name <- toy.field("name", toy.string)
  use date <- toy.field("date", custom_decoders.day_decoder("date"))
  use google_maps_link <- toy.field(
    "google_maps_link",
    toy.string |> toy.nullable,
  )

  toy.decoded(UserTripPlace(trip_place_id:, name:, date:, google_maps_link:))
}

pub fn user_trip_place_encoder(data: UserTripPlace) {
  json.object([
    #("trip_place_id", json.string(data.trip_place_id |> string.lowercase)),
    #("name", json.string(data.name)),
    #("date", json.string(data.date |> custom_encoders.day_to_string)),
    #("google_maps_link", json.nullable(data.google_maps_link, of: json.string)),
  ])
}

pub fn user_trip_places_decoder() {
  use trip_id <- toy.field("trip_id", toy.string)
  use destination <- toy.field("destination", toy.string)
  use start_date <- toy.field(
    "start_date",
    custom_decoders.day_decoder("start_date"),
  )
  use end_date <- toy.field("end_date", custom_decoders.day_decoder("end_date"))
  use user_trip_places <- toy.field(
    "user_trip_places",
    toy.list(user_trip_place_decoder()),
  )
  use user_trip_companions <- toy.field(
    "user_trip_companions",
    toy.list(user_trip_companion_decoder()),
  )

  toy.decoded(UserTripPlaces(
    trip_id:,
    destination:,
    start_date:,
    end_date:,
    user_trip_places:,
    user_trip_companions:,
  ))
}

pub fn user_trip_places_encoder(data: UserTripPlaces) {
  json.object([
    #("trip_id", json.string(data.trip_id |> string.lowercase)),
    #("destination", json.string(data.destination)),
    #(
      "start_date",
      json.string(data.start_date |> custom_encoders.day_to_string),
    ),
    #("end_date", json.string(data.end_date |> custom_encoders.day_to_string)),
    #(
      "user_trip_places",
      json.array(from: data.user_trip_places, of: user_trip_place_encoder),
    ),
    #(
      "user_trip_companions",
      json.array(
        from: data.user_trip_companions,
        of: user_trip_companion_encoder,
      ),
    ),
  ])
}

pub type UserTripCompanion {
  UserTripCompanion(trip_companion_id: String, name: String, email: String)
}

pub fn default_user_trip_companion() {
  UserTripCompanion(trip_companion_id: "", name: "", email: "")
}

pub fn user_trip_companion_decoder() {
  use trip_companion_id <- toy.field("trip_companion_id", toy.string)
  use name <- toy.field("name", toy.string)
  use email <- toy.field("email", toy.string |> toy.string_email)

  toy.decoded(UserTripCompanion(trip_companion_id:, name:, email:))
}

pub fn user_trip_companion_encoder(data: UserTripCompanion) {
  json.object([
    #(
      "trip_companion_id",
      json.string(data.trip_companion_id |> string.lowercase),
    ),
    #("name", json.string(data.name)),
    #("email", json.string(data.email)),
  ])
}

//

pub type CreateTripRequest {
  CreateTripRequest(
    destination: String,
    start_date: birl.Day,
    end_date: birl.Day,
  )
}

pub fn default_create_trip_request() {
  CreateTripRequest(
    destination: "",
    start_date: default_day,
    end_date: default_day,
  )
}

pub fn create_trip_request_decoder() {
  use destination <- toy.field("destination", toy.string |> toy.string_nonempty)
  use start_date <- toy.field(
    "start_date",
    custom_decoders.day_decoder("start_date"),
  )
  use end_date <- toy.field("end_date", custom_decoders.day_decoder("end_date"))

  toy.decoded(CreateTripRequest(destination:, start_date:, end_date:))
}

pub fn create_trip_request_encoder(data: CreateTripRequest) {
  json.object([
    #("destination", json.string(data.destination)),
    #(
      "start_date",
      json.string(data.start_date |> custom_encoders.day_to_string),
    ),
    #("end_date", json.string(data.end_date |> custom_encoders.day_to_string)),
  ])
}

//

pub type CreateTripPlaceRequest {
  CreateTripPlaceRequest(
    place: String,
    date: birl.Day,
    google_maps_link: Option(String),
  )
}

pub fn default_create_trip_place_request() {
  CreateTripPlaceRequest(
    place: "",
    date: default_day,
    google_maps_link: option.None,
  )
}

pub fn create_trip_place_request_decoder() {
  use place <- toy.field("place", toy.string |> toy.string_nonempty)
  use date <- toy.field("date", custom_decoders.day_decoder("date"))
  use google_maps_link <- toy.field(
    "google_maps_link",
    toy.string |> toy.string_nonempty |> toy.nullable,
  )

  toy.decoded(CreateTripPlaceRequest(place:, date:, google_maps_link:))
}

pub fn create_trip_place_request_encoder(data: CreateTripPlaceRequest) {
  json.object([
    #("place", json.string(data.place)),
    #("date", json.string(data.date |> custom_encoders.day_to_string)),
    #("google_maps_link", json.nullable(data.google_maps_link, of: json.string)),
  ])
}

//

pub type UpdateTripCompanionsRequest {
  UpdateTripCompanionsRequest(trip_companions: List(TripCompanion))
}

pub fn update_trip_companions_request_encoder(data: UpdateTripCompanionsRequest) {
  json.object([
    #(
      "trip_companions",
      json.array(from: data.trip_companions, of: trip_companion_encoder),
    ),
  ])
}

pub fn trip_companion_encoder(data: TripCompanion) {
  json.object([
    #(
      "trip_companion_id",
      json.string(data.trip_companion_id |> string.lowercase),
    ),
    #("name", json.string(data.name)),
    #("email", json.string(data.email)),
  ])
}

pub fn update_trip_companions_request_decoder() {
  use trip_companions <- toy.field(
    "trip_companions",
    toy.list(trip_companion_decoder()),
  )

  toy.decoded(UpdateTripCompanionsRequest(trip_companions:))
}

pub type TripCompanion {
  TripCompanion(trip_companion_id: String, name: String, email: String)
}

pub fn trip_companion_decoder() {
  use trip_companion_id <- toy.field(
    "trip_companion_id",
    toy.string |> toy.string_nonempty,
  )
  use name <- toy.field("name", toy.string |> toy.string_nonempty)
  use email <- toy.field("email", toy.string |> toy.string_nonempty)

  toy.decoded(TripCompanion(trip_companion_id:, name:, email:))
}

// 

pub type UpdateTripRequest {
  UpdateTripRequest(
    destination: String,
    start_date: birl.Day,
    end_date: birl.Day,
  )
}

pub fn default_update_trip_request() {
  UpdateTripRequest(
    destination: "",
    start_date: default_day,
    end_date: default_day,
  )
}

pub fn update_trip_request_decoder() {
  use destination <- toy.field("destination", toy.string |> toy.string_nonempty)
  use start_date <- toy.field(
    "start_date",
    custom_decoders.day_decoder("start_date"),
  )
  use end_date <- toy.field("end_date", custom_decoders.day_decoder("end_date"))

  toy.decoded(UpdateTripRequest(destination:, start_date:, end_date:))
}

pub fn update_trip_request_encoder(data: UpdateTripRequest) {
  json.object([
    #("destination", json.string(data.destination)),
    #(
      "start_date",
      json.string(data.start_date |> custom_encoders.day_to_string),
    ),
    #("end_date", json.string(data.end_date |> custom_encoders.day_to_string)),
  ])
}
//
