import decode
import gleam/json
import shared/uuid_utils
import youid/uuid.{type Uuid}

//

pub type UserTrip {
  UserTrip(trip_id: Uuid, destination: String, places_count: Int)
}

pub fn user_trip_decoder() {
  decode.into({
    use trip_id <- decode.parameter
    use destination <- decode.parameter
    use places_count <- decode.parameter
    UserTrip(trip_id:, destination:, places_count:)
  })
  |> decode.field("trip_id", uuid_utils.uuid_decoder_from_string())
  |> decode.field("destination", decode.string)
  |> decode.field("places_count", decode.int)
}

pub fn user_trip_encoder(data: UserTrip) {
  json.object([
    #("trip_id", json.string(uuid.to_string(data.trip_id))),
    #("destination", json.string(data.destination)),
    #("places_count", json.int(data.places_count)),
  ])
}

pub type UserTrips {
  UserTrips(user_trips: List(UserTrip))
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
  UserTripPlace(trip_place_id: String, name: String)
}

pub type UserTripPlaces {
  UserTripPlaces(
    trip_id: String,
    destination: String,
    user_trip_places: List(UserTripPlace),
  )
}

pub fn user_trip_place_decoder() {
  decode.into({
    use trip_place_id <- decode.parameter
    use name <- decode.parameter

    UserTripPlace(trip_place_id:, name:)
  })
  |> decode.field("trip_place_id", decode.string)
  |> decode.field("name", decode.string)
}

pub fn user_trip_place_encoder(data: UserTripPlace) {
  json.object([
    #("trip_place_id", json.string(data.trip_place_id)),
    #("name", json.string(data.name)),
  ])
}

pub fn user_trip_places_decoder() {
  decode.into({
    use trip_id <- decode.parameter
    use destination <- decode.parameter
    use user_trip_places <- decode.parameter

    UserTripPlaces(trip_id:, destination:, user_trip_places:)
  })
  |> decode.field("trip_id", decode.string)
  |> decode.field("destination", decode.string)
  |> decode.field("user_trip_places", decode.list(user_trip_place_decoder()))
}

pub fn user_trip_places_encoder(data: UserTripPlaces) {
  json.object([
    #("trip_id", json.string(data.trip_id)),
    #("destination", json.string(data.destination)),
    #(
      "user_trip_places",
      json.array(from: data.user_trip_places, of: user_trip_place_encoder),
    ),
  ])
}

//

pub type CreateTripRequest {
  CreateTripRequest(destination: String)
}

pub fn create_trip_request_decoder() {
  decode.into({
    use destination <- decode.parameter
    CreateTripRequest(destination:)
  })
  |> decode.field("destination", decode.string)
}

pub fn create_trip_request_encoder(data: CreateTripRequest) {
  json.object([#("destination", json.string(data.destination))])
}
