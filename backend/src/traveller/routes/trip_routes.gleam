import gleam/result
import shared/id.{type Id, type TripId, type UserId}
import shared/trips.{type CreateTripRequest, type UserTrips}
import traveller/database/trips_db
import traveller/error.{type AppError}
import traveller/web.{type Context}

/// Returns list of places for a trip set by user
pub fn handle_get_trip_places(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(trips.UserTripPlaces, AppError) {
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
  trips_db.create_user_trip(ctx, user_id, create_trip_request)
}
