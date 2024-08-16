import gleam/list
import gleam/pgo
import gleam/result
import shared/trips
import traveller/database
import traveller/error.{type AppError}
import traveller/sql
import traveller/web.{type Context}

pub fn get_user_trips(
  ctx: Context,
  userid: String,
) -> Result(trips.UserTrips, AppError) {
  use pgo.Returned(_, rows) <- result.map(
    sql.get_user_trips(ctx.db, userid)
    |> database.map_error(),
  )

  trips.UserTrips(
    user_trips: rows
    |> list.map(fn(row) { trips.UserTrip(destination: row.destination) }),
  )
}
