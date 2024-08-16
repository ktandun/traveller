import gleam_community/codec

pub type UserTrip {
  UserTrip(destination: String)
}

pub type UserTrips {
  UserTrips(user_trips: List(UserTrip))
}

pub type CreateTripRequest {
  CreateTripRequest(destination: String)
}

pub fn user_trip_codec() {
  codec.custom({
    use user_trip_codec <- codec.variant1("UserTrip", UserTrip, codec.string())
    codec.make_custom(fn(value) {
      case value {
        UserTrip(destination) -> user_trip_codec(destination)
      }
    })
  })
}

pub fn user_trips_codec() {
  codec.custom({
    use user_trips_codec <- codec.variant1(
      "UserTrips",
      UserTrips,
      codec.list(user_trip_codec()),
    )

    codec.make_custom(fn(value) {
      case value {
        UserTrips(user_trips) -> user_trips_codec(user_trips)
      }
    })
  })
}

pub fn create_trip_request_codec() {
  codec.custom({
    use create_trip_request_codec <- codec.variant1("CreateTripRequest", CreateTripRequest, codec.string())
    codec.make_custom(fn(value) {
      case value {
        CreateTripRequest(destination) -> create_trip_request_codec(destination)
      }
    })
  })
}
