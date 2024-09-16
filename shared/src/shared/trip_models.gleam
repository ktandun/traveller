import birl
import gleam/json
import gleam/option.{type Option}
import gleam/string
import shared/custom_decoders
import shared/date_util_shared
import toy.{type Decoder}

//

pub type UserTrip {
  UserTrip(
    trip_id: String,
    destination: String,
    start_date: birl.Day,
    end_date: birl.Day,
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

  toy.decoded(UserTrip(trip_id:, destination:, start_date:, end_date:))
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
    accomodation_name: Option(String),
    accomodation_information_url: Option(String),
    accomodation_fee: Option(Float),
    activities: List(UserTripPlaceActivity),
    culinaries: List(UserTripPlaceCulinary),
  )
}

pub type UserTripPlaceActivity {
  UserTripPlaceActivity(
    name: String,
    information_url: Option(String),
    start_time: Option(String),
    end_time: Option(String),
    entry_fee: Option(Float),
  )
}

pub type UserTripPlaceCulinary {
  UserTripPlaceCulinary(
    name: String,
    information_url: Option(String),
    open_time: Option(String),
    close_time: Option(String),
  )
}

pub type UserTripPlaces {
  UserTripPlaces(
    trip_id: String,
    destination: String,
    start_date: birl.Day,
    end_date: birl.Day,
    total_activities_fee: Float,
    total_accomodations_fee: Float,
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
    total_activities_fee: 0.0,
    total_accomodations_fee: 0.0,
    user_trip_places: [],
    user_trip_companions: [],
  )
}

pub fn user_trip_place_activity_decoder() -> Decoder(UserTripPlaceActivity) {
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

  toy.decoded(UserTripPlaceActivity(
    name:,
    information_url:,
    start_time:,
    end_time:,
    entry_fee:,
  ))
}

pub fn user_trip_place_activity_encoder(data: UserTripPlaceActivity) {
  json.object([
    #("name", json.string(data.name)),
    #("information_url", json.nullable(data.information_url, json.string)),
    #("start_time", json.nullable(data.start_time, json.string)),
    #("end_time", json.nullable(data.end_time, json.string)),
    #("entry_fee", json.nullable(data.entry_fee, json.float)),
  ])
}

pub fn user_trip_place_culinary_decoder() -> Decoder(UserTripPlaceCulinary) {
  use name <- toy.field("name", toy.string)
  use information_url <- toy.field(
    "information_url",
    toy.string |> toy.nullable,
  )
  use open_time <- toy.field("open_time", toy.string |> toy.nullable)
  use close_time <- toy.field("close_time", toy.string |> toy.nullable)

  toy.decoded(UserTripPlaceCulinary(
    name:,
    information_url:,
    open_time:,
    close_time:,
  ))
}

pub fn user_trip_place_culinary_encoder(data: UserTripPlaceCulinary) {
  json.object([
    #("name", json.string(data.name)),
    #("information_url", json.nullable(data.information_url, json.string)),
    #("open_time", json.nullable(data.open_time, json.string)),
    #("close_time", json.nullable(data.close_time, json.string)),
  ])
}

pub fn user_trip_place_decoder() -> Decoder(UserTripPlace) {
  use trip_place_id <- toy.field("trip_place_id", toy.string)
  use name <- toy.field("name", toy.string)
  use date <- toy.field("date", custom_decoders.day_decoder("date"))
  use has_accomodation <- toy.field("has_accomodation", toy.bool)
  use accomodation_paid <- toy.field("accomodation_paid", toy.bool)
  use accomodation_name <- toy.field(
    "accomodation_name",
    toy.string |> toy.nullable,
  )
  use accomodation_information_url <- toy.field(
    "accomodation_information_url",
    toy.string |> toy.nullable,
  )
  use accomodation_fee <- toy.field(
    "accomodation_fee",
    custom_decoders.number |> toy.nullable,
  )
  use activities <- toy.field(
    "activities",
    user_trip_place_activity_decoder() |> toy.list,
  )
  use culinaries <- toy.field(
    "culinaries",
    user_trip_place_culinary_decoder() |> toy.list,
  )

  toy.decoded(UserTripPlace(
    trip_place_id:,
    name:,
    date:,
    has_accomodation:,
    accomodation_paid:,
    accomodation_name:,
    accomodation_information_url:,
    accomodation_fee:,
    activities:,
    culinaries:,
  ))
}

pub fn user_trip_place_encoder(data: UserTripPlace) {
  json.object([
    #("trip_place_id", json.string(data.trip_place_id |> string.lowercase)),
    #("name", json.string(data.name)),
    #("date", json.string(data.date |> date_util_shared.to_yyyy_mm_dd)),
    #("has_accomodation", json.bool(data.has_accomodation)),
    #("accomodation_paid", json.bool(data.accomodation_paid)),
    #("accomodation_name", json.nullable(data.accomodation_name, json.string)),
    #(
      "accomodation_information_url",
      json.nullable(data.accomodation_information_url, json.string),
    ),
    #("accomodation_fee", json.nullable(data.accomodation_fee, json.float)),
    #(
      "activities",
      json.array(data.activities, of: user_trip_place_activity_encoder),
    ),
    #(
      "culinaries",
      json.array(data.culinaries, of: user_trip_place_culinary_encoder),
    ),
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
  use total_activities_fee <- toy.field(
    "total_activities_fee",
    custom_decoders.number,
  )
  use total_accomodations_fee <- toy.field(
    "total_accomodations_fee",
    custom_decoders.number,
  )
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
    total_activities_fee:,
    total_accomodations_fee:,
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
    #("total_activities_fee", json.float(data.total_activities_fee)),
    #("total_accomodations_fee", json.float(data.total_accomodations_fee)),
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

pub type PlaceActivities {
  PlaceActivities(
    trip_id: String,
    trip_place_id: String,
    place_name: String,
    place_activities: List(PlaceActivity),
  )
}

//

pub type PlaceAccomodation {
  PlaceAccomodation(
    place_accomodation_id: String,
    place_name: String,
    accomodation_name: String,
    information_url: Option(String),
    accomodation_fee: Option(Float),
    paid: Bool,
  )
}

pub fn default_place_accomodation() {
  PlaceAccomodation(
    place_accomodation_id: "",
    place_name: "",
    accomodation_name: "",
    information_url: option.None,
    accomodation_fee: option.None,
    paid: False,
  )
}

//

pub type PlaceCulinaries {
  PlaceCulinaries(
    trip_id: String,
    trip_place_id: String,
    place_name: String,
    place_culinaries: List(PlaceCulinary),
  )
}

pub type PlaceCulinary {
  PlaceCulinary(
    place_culinary_id: String,
    name: String,
    information_url: Option(String),
    open_time: Option(String),
    close_time: Option(String),
  )
}
