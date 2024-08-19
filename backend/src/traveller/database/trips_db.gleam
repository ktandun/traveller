import gleam/list
import gleam/pgo
import gleam/result
import shared/id.{type Id, type TripId, type UserId}
import shared/trips.{type CreateTripRequest}
import traveller/database
import traveller/error.{type AppError}
import traveller/sql
import traveller/web.{type Context}
import youid/uuid

pub fn get_user_trips(
  ctx: Context,
  user_id: Id(UserId),
) -> Result(trips.UserTrips, AppError) {
  let user_id = id.id_value(user_id)

  use pgo.Returned(_, rows) <- result.map(
    sql.get_user_trips(ctx.db, user_id)
    |> database.to_app_error(),
  )

  trips.UserTrips(
    user_trips: rows
    |> list.map(fn(row) { trips.UserTrip(destination: row.destination) }),
  )
}

pub fn create_user_trip(
  ctx: Context,
  user_id: Id(UserId),
  create_trip_request: CreateTripRequest,
) -> Result(Id(TripId), AppError) {
  let new_trip_id = ctx.uuid_provider()
  let user_id = id.id_value(user_id)

  use pgo.Returned(_, _) <- result.try(
    sql.create_trip(ctx.db, new_trip_id, create_trip_request.destination)
    |> database.to_app_error(),
  )

  use pgo.Returned(_, _) <- result.try(
    sql.create_user_trip(ctx.db, user_id, new_trip_id)
    |> database.to_app_error(),
  )

  Ok(id.to_id(uuid.to_string(new_trip_id)))
}

pub fn get_user_trip_places(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(String, AppError) {
  let user_id = id.id_value(user_id)
  let trip_id = id.id_value(trip_id)

  use query_result <- result.try(
    sql.get_user_trip_places(ctx.db, user_id, trip_id)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_user_trip_places")

  let sql.GetUserTripPlacesRow(row) = row

  Ok(row)
}

pub fn ensure_trip_id_exists(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(Nil, AppError) {
  let trip_id = id.id_value(trip_id)
  let user_id = id.id_value(user_id)

  use query_result <- result.try(
    sql.find_trip_by_trip_id(ctx.db, user_id, trip_id)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "find_trip_by_trip_id")

  let sql.FindTripByTripIdRow(row) = row

  case row {
    1 -> Ok(Nil)
    _ -> Error(error.TripDoesNotExist)
  }
}
