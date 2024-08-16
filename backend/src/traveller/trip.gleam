import gleam/dynamic
import gleam/list
import gleam/pgo
import gleam/result
import shared/trips
import traveller/database
import traveller/error.{type AppError}
import traveller/sql

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
  uuid_provider: fn() -> String,
  user_id: String,
) -> Result(trips.TripId, pgo.TransactionError) {
  use conn <- pgo.transaction(conn)

  let assert Ok(trip_id) = create_trip(conn, uuid_provider, "Paris")
  let assert Ok(Nil) = create_user_trip2(conn, user_id, trip_id)

  Ok(trips.TripId(trip_id))
}

fn create_trip(
  conn: pgo.Connection,
  uuid_provider: fn() -> String,
  destination: String,
) -> Result(String, pgo.QueryError) {
  let trip_id = uuid_provider()

  let sql =
    "
    insert into trips (tripid, destination)
    values ($1, $2)
    "

  use _ <- result.try(pgo.execute(
    sql,
    conn,
    [pgo.text(trip_id), pgo.text(destination)],
    dynamic.dynamic,
  ))

  Ok(trip_id)
}

fn create_user_trip2(
  conn: pgo.Connection,
  user_id: String,
  trip_id: String,
) -> Result(Nil, pgo.QueryError) {
  let sql =
    "
    insert into user_trips (userid, tripid)
    values ($1, $2)
    "

  use _ <- result.try(pgo.execute(
    sql,
    conn,
    [pgo.text(user_id), pgo.text(trip_id)],
    dynamic.dynamic,
  ))

  Ok(Nil)
}
