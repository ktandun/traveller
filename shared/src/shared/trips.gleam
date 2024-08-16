import gleam_community/codec

pub type TripId {
  TripId(trip_id: String)
}

pub type UserTrip {
  UserTrip(destination: String)
}

pub type UserTrips {
  UserTrips(user_trips: List(UserTrip))
}

pub fn trip_id_codec() {
  codec.custom({
    use trip_id_codec <- codec.variant1("TripId", TripId, codec.string())

    codec.make_custom(fn(value) {
      case value {
        TripId(trip_id) -> trip_id_codec(trip_id)
      }
    })
  })
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
