import birl
import gleam/json
import gleam/option.{type Option}
import gleam/string
import shared/custom_decoders
import shared/date_util_shared
import toy

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
      json.string(data.start_date |> date_util_shared.to_yyyy_mm_dd),
    ),
    #("end_date", json.string(data.end_date |> date_util_shared.to_yyyy_mm_dd)),
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
    has_accomodation: Bool,
    accomodation_paid: Bool,
    activities_count: Int,
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
    start_date: birl.Day(1, 1, 1),
    end_date: birl.Day(1, 1, 1),
    user_trip_places: [],
    user_trip_companions: [],
  )
}

pub fn user_trip_place_decoder() {
  use trip_place_id <- toy.field("trip_place_id", toy.string)
  use name <- toy.field("name", toy.string)
  use date <- toy.field("date", custom_decoders.day_decoder("date"))
  use has_accomodation <- toy.field("has_accomodation", toy.bool)
  use accomodation_paid <- toy.field("accomodation_paid", toy.bool)
  use activities_count <- toy.field("activities_count", toy.int)

  toy.decoded(UserTripPlace(
    trip_place_id:,
    name:,
    date:,
    has_accomodation:,
    accomodation_paid:,
    activities_count:,
  ))
}

pub fn user_trip_place_encoder(data: UserTripPlace) {
  json.object([
    #("trip_place_id", json.string(data.trip_place_id |> string.lowercase)),
    #("name", json.string(data.name)),
    #("date", json.string(data.date |> date_util_shared.to_yyyy_mm_dd)),
    #("has_accomodation", json.bool(data.has_accomodation)),
    #("accomodation_paid", json.bool(data.accomodation_paid)),
    #("activities_count", json.int(data.activities_count)),
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
      json.string(data.start_date |> date_util_shared.to_yyyy_mm_dd),
    ),
    #("end_date", json.string(data.end_date |> date_util_shared.to_yyyy_mm_dd)),
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
    start_date: birl.Day(1, 1, 1),
    end_date: birl.Day(1, 1, 1),
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
      json.string(data.start_date |> date_util_shared.to_yyyy_mm_dd),
    ),
    #("end_date", json.string(data.end_date |> date_util_shared.to_yyyy_mm_dd)),
  ])
}

//

pub type CreateTripPlaceRequest {
  CreateTripPlaceRequest(place: String, date: birl.Day)
}

pub fn default_create_trip_place_request() {
  CreateTripPlaceRequest(place: "", date: birl.Day(1, 1, 1))
}

pub fn create_trip_place_request_decoder() {
  use place <- toy.field("place", toy.string |> toy.string_nonempty)
  use date <- toy.field("date", custom_decoders.day_decoder("date"))

  toy.decoded(CreateTripPlaceRequest(place:, date:))
}

pub fn create_trip_place_request_encoder(data: CreateTripPlaceRequest) {
  json.object([
    #("place", json.string(data.place)),
    #("date", json.string(data.date |> date_util_shared.to_yyyy_mm_dd)),
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
  use email <- toy.field(
    "email",
    toy.string |> toy.string_email |> toy.string_nonempty,
  )

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
    start_date: birl.Day(1, 1, 1),
    end_date: birl.Day(1, 1, 1),
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
      json.string(data.start_date |> date_util_shared.to_yyyy_mm_dd),
    ),
    #("end_date", json.string(data.end_date |> date_util_shared.to_yyyy_mm_dd)),
  ])
}

//

pub type PlaceActivity {
  PlaceActivity(
    place_activity_id: String,
    name: String,
    information_url: Option(String),
    start_time: Option(String),
    end_time: Option(String),
    entry_fee: Option(Float),
  )
}

pub fn place_activity_decoder() {
  use place_activity_id <- toy.field("place_activity_id", toy.string)
  use name <- toy.field("name", toy.string)
  use information_url <- toy.field(
    "information_url",
    toy.string |> toy.nullable,
  )
  use start_time <- toy.field("start_time", toy.string |> toy.nullable)
  use end_time <- toy.field("end_time", toy.string |> toy.nullable)
  use entry_fee <- toy.field(
    "entry_fee",
    custom_decoders.number |> toy.nullable,
  )

  toy.decoded(PlaceActivity(
    place_activity_id:,
    name:,
    information_url:,
    start_time:,
    end_time:,
    entry_fee:,
  ))
}

pub fn place_activity_encoder(data: PlaceActivity) {
  json.object([
    #("place_activity_id", json.string(data.place_activity_id)),
    #("name", json.string(data.name)),
    #("information_url", json.nullable(data.information_url, json.string)),
    #("start_time", json.nullable(data.start_time, json.string)),
    #("end_time", json.nullable(data.end_time, json.string)),
    #("entry_fee", json.nullable(data.entry_fee, json.float)),
  ])
}

pub type PlaceActivities {
  PlaceActivities(
    trip_id: String,
    trip_place_id: String,
    place_name: String,
    place_activities: List(PlaceActivity),
  )
}

pub fn place_activities_decoder() {
  use trip_id <- toy.field("trip_id", toy.string)
  use trip_place_id <- toy.field("trip_place_id", toy.string)
  use place_name <- toy.field("place_name", toy.string)
  use place_activities <- toy.field(
    "place_activities",
    toy.list(place_activity_decoder()),
  )

  toy.decoded(PlaceActivities(
    trip_id:,
    trip_place_id:,
    place_name:,
    place_activities:,
  ))
}

pub fn place_activities_encoder(data: PlaceActivities) {
  json.object([
    #("trip_id", json.string(data.trip_id)),
    #("trip_place_id", json.string(data.trip_place_id)),
    #("place_name", json.string(data.place_name)),
    #(
      "place_activities",
      json.array(from: data.place_activities, of: place_activity_encoder),
    ),
  ])
}
