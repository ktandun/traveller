import birl
import gleam/bool
import gleam/list
import gleam/result
import gleam/string
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{
  type CreateTripPlaceRequest, type CreateTripRequest,
  type UpdateTripCompanionsRequest, type UserTrips,
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
  create_trip_request: CreateTripRequest,
) -> Result(Id(TripId), AppError) {
  let now = birl.now()

  use #(start_year, start_month, start_date) <- result.try(
    date_util.from_yyyy_mm_dd(create_trip_request.start_date),
  )
  use #(end_year, end_month, end_date) <- result.try(date_util.from_yyyy_mm_dd(
    create_trip_request.end_date,
  ))
  let start_date =
    birl.set_day(now, birl.Day(start_year, start_month, start_date))
  let end_date = birl.set_day(now, birl.Day(end_year, end_month, end_date))

  use <- bool.guard(
    birl.to_unix(end_date) < birl.to_unix(start_date),
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

  use is_date_valid <- result.try(date_util.is_date_within(
    request.date,
    start_date,
    end_date,
  ))

  use <- bool.guard(!is_date_valid, Error(error.InvalidDateSpecified))

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
      !string.is_empty(companion.name) && !string.is_empty(companion.email)
    })

  use _ <- result.try(trips_db.delete_trip_companions(ctx, trip_id))

  trips_db.upsert_trip_companion(ctx, trip_id, request)
}
