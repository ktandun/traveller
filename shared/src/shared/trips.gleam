import decode
import gleam/json

//

pub type UserTrip {
  UserTrip(destination: String)
}

pub fn user_trip_decoder() {
  decode.into({
    use destination <- decode.parameter
    UserTrip(destination:)
  })
  |> decode.field("destination", decode.string)
}

pub fn user_trip_encoder(data: UserTrip) {
  json.object([#("destination", json.string(data.destination))])
}

//

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
