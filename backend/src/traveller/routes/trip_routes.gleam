import gleam/bool
import gleam/list
import gleam/result
import gleam/string
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{
  type CreateTripPlaceRequest, type CreateTripRequest,
  type UpdateTripCompanionsRequest, type UpdateTripRequest, type UserTrips,
}
import traveller/database/trips_db
import traveller/date_util
import traveller/error.{type AppError}
import traveller/web.{type Context}
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
/// Ensures start_date < end_date
pub fn handle_create_trip(
  ctx: Context,
  user_id: Id(UserId),
  create_request: CreateTripRequest,
) -> Result(Id(TripId), AppError) {
  use <- bool.guard(
    date_util.is_before(create_request.end_date, create_request.start_date),
    Error(error.InvalidDateSpecified),
  )

  use <- bool.guard(
    string.is_empty(create_request.destination |> string.trim),
    Error(error.InvalidDestinationSpecified),
  )

  trips_db.create_user_trip(ctx, user_id, create_request)
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

/// Creates a trip place for a user
/// Ensures date is between trip start_date and end_date
pub fn handle_create_trip_place(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  request: CreateTripPlaceRequest,
) -> Result(Id(TripPlaceId), AppError) {
  use #(start_date, end_date) <- result.try(
    trips_db.get_user_trip_dates_by_trip_id(ctx, user_id, trip_id),
  )

  use <- bool.guard(
    !date_util.is_date_within(request.date, start_date, end_date),
    Error(error.InvalidDateSpecified),
  )

  let trip_place_id = ctx.uuid_provider() |> uuid.to_string |> id.to_id()

  use _ <- result.try(trips_db.upsert_trip_place(
    ctx,
    trip_id,
    trip_place_id,
    request,
  ))

  Ok(trip_place_id)
}

pub fn handle_update_trip_companions(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  request: UpdateTripCompanionsRequest,
) -> Result(List(Nil), AppError) {
  use _ <- result.try(trips_db.ensure_trip_id_exists(ctx, user_id, trip_id))

  let request =
    request.trip_companions
    |> list.filter(fn(companion) {
      !string.is_empty(companion.name |> string.trim)
      && !string.is_empty(companion.email |> string.trim)
    })

  use _ <- result.try(trips_db.delete_trip_companions(ctx, trip_id))

  trips_db.upsert_trip_companion(ctx, trip_id, request)
}

// Update trip details
pub fn handle_update_trip(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  update_trip_request: UpdateTripRequest,
) -> Result(Id(TripId), AppError) {
  use _ <- result.try(trips_db.ensure_trip_id_exists(ctx, user_id, trip_id))

  use <- bool.guard(
    date_util.is_before(
      update_trip_request.end_date,
      update_trip_request.start_date,
    ),
    Error(error.InvalidDateSpecified),
  )

  use <- bool.guard(
    string.is_empty(update_trip_request.destination |> string.trim),
    Error(error.InvalidDestinationSpecified),
  )

  use _ <- result.try(trips_db.update_user_trip(
    ctx,
    trip_id,
    update_trip_request,
  ))

  Ok(trip_id)
}
