import gleam/list
import gleam/pgo
import gleam/result
import gleam_community/codec
import traveller/database
import traveller/error.{type AppError}
import traveller/sql
import traveller/web.{type Context}

pub type UserTrip {
  UserTrip(destination: String)
}

pub type UserTrips {
  UserTrips(user_trips: List(UserTrip))
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

pub fn get_user_trips(
  ctx: Context,
  userid: String,
) -> Result(UserTrips, AppError) {
  use pgo.Returned(_, rows) <- result.map(
    sql.get_user_trips(ctx.db, userid)
    |> database.map_error(),
  )

  UserTrips(
    user_trips: rows
    |> list.map(fn(row) { UserTrip(destination: row.destination) }),
  )
}
