import gleam/list
import gleam/pgo
import gleam/result
import shared/trips
import traveller/database
import traveller/error.{type AppError}
import traveller/sql
import traveller/web.{type Context}

pub fn get_user_trips(
  conn: pgo.Connection,
  userid: String,
) -> Result(trips.UserTrips, AppError) {
  use pgo.Returned(_, rows) <- result.map(
    sql.get_user_trips(conn, userid)
    |> database.map_error(),
  )

  trips.UserTrips(
    user_trips: rows
    |> list.map(fn(row) { trips.UserTrip(destination: row.destination) }),
  )
}

pub fn create_user_trip(
  conn: pgo.Connection,
  userid: String,
) -> Result(trips.UserTrips, AppError) {
  todo
}
