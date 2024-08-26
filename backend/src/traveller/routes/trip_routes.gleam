import birl
import gleam/bool
import gleam/io
import gleam/order
import gleam/string
import gleam/result
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{type CreateTripRequest, type UserTrips}
import traveller/database/trips_db
import traveller/error.{type AppError}
import traveller/web.{type Context}
import wisp
import youid/uuid

/// Returns list of places for a trip set by user
pub fn handle_get_trip_places(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(trip_models.UserTripPlaces, AppError) {
  let trip_id_value = id.id_value(trip_id)

  use _ <- result.try(
    uuid.from_string(trip_id_value)
    |> result.map_error(fn(_) { error.InvalidUUIDString(trip_id_value) }),
  )

  use _ <- result.try(trips_db.ensure_trip_id_exists(ctx, user_id, trip_id))

  trips_db.get_user_trip_places(ctx, user_id, trip_id)
}

/// Returns list of trips set by user
pub fn handle_get_trips(
  ctx: Context,
  user_id: Id(UserId),
) -> Result(UserTrips, AppError) {
  trips_db.get_user_trips(ctx, user_id)
}

/// Creates a trip for a user
pub fn handle_create_trip(
  ctx: Context,
  user_id: Id(UserId),
  create_trip_request: CreateTripRequest,
) -> Result(Id(TripId), AppError) {
  let assert Ok(start_date_date) = birl.parse(create_trip_request.start_date)
  let assert Ok(end_date_date) = birl.parse(create_trip_request.end_date)

  use <- bool.guard(
    birl.compare(start_date_date, end_date_date) == order.Gt,
    Error(error.InvalidDateSpecified),
  )

  use <- bool.guard(
    string.is_empty(create_trip_request.destination),
    Error(error.InvalidDestinationSpecified),
  )

  trips_db.create_user_trip(ctx, user_id, create_trip_request)
}

/// Deletes a trip place for a user
pub fn handle_delete_trip_place(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) {
  trips_db.delete_user_trip_place(ctx, user_id, trip_id, trip_place_id)
}
