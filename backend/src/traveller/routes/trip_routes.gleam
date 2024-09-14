import gleam/bool
import gleam/list
import gleam/option
import gleam/pgo
import gleam/result
import gleam/string
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{
  type CreateTripPlaceRequest, type CreateTripRequest, type PlaceAccomodation,
  type PlaceActivities, type UpdateTripCompanionsRequest, type UpdateTripRequest,
  type UserTrips,
}
import traveller/context.{type Context}
import traveller/database/trips_db
import traveller/date_util
import traveller/error.{type AppError}
import youid/uuid

/// Returns list of places for a trip set by user
pub fn handle_get_trip_places(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(trip_models.UserTripPlaces, AppError) {
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
    Error(error.ValidationFailed("Date specified is not within trip dates")),
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
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  trips_db.delete_user_trip_place(ctx, trip_place_id)
}

/// Creates a trip place for a user
/// Ensures date is between trip start_date and end_date
pub fn handle_upsert_trip_place(
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
    Error(error.ValidationFailed("Date specified is not within trip dates")),
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
    Error(error.ValidationFailed("Start date specified is after end date")),
  )

  use _ <- result.try(trips_db.update_user_trip(
    ctx,
    trip_id,
    update_trip_request,
  ))

  Ok(trip_id)
}

// Retrieve all user's trip place activities
pub fn handle_get_place_activities(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(PlaceActivities, AppError) {
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  use place_activities <- result.try(trips_db.get_place_activities(
    ctx,
    trip_id,
    trip_place_id,
  ))

  Ok(place_activities)
}

// Update user's trip place activities
pub fn handle_update_place_activities(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
  update_request: trip_models.PlaceActivities,
) -> Result(Nil, AppError) {
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  use _ <- result.try(trips_db.delete_place_activities(ctx, trip_place_id))

  use _ <- result.try(trips_db.create_place_activities(
    ctx,
    trip_id,
    trip_place_id,
    update_request,
  ))

  Ok(Nil)
}

// Retrieve all user's trip place accomodations
pub fn handle_get_place_accomodation(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(PlaceAccomodation, AppError) {
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  trips_db.get_place_accomodation(ctx, trip_place_id)
  |> result.map(fn(accomodation) {
    option.unwrap(accomodation, trip_models.default_place_accomodation())
  })
}

pub fn handle_update_place_accomodation(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
  update_request: trip_models.PlaceAccomodation,
) -> Result(Nil, AppError) {
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  trips_db.update_place_accomodation(ctx, trip_place_id, update_request)
}

pub fn handle_get_trip_place_culinaries(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(trip_models.PlaceCulinaries, AppError) {
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  trips_db.get_place_culinaries(ctx, trip_place_id)
}

pub fn handle_update_place_culinaries(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
  update_request: trip_models.PlaceCulinaries,
) -> Result(Nil, AppError) {
  use _ <- result.try(trips_db.ensure_trip_place_id_exists(
    ctx,
    user_id,
    trip_id,
    trip_place_id,
  ))

  pgo.transaction(ctx.db, fn(db_conn) {
    use _ <- result.try(
      trips_db.delete_place_culinaries(
        ctx |> context.with_db_conn(db_conn),
        trip_place_id,
      )
      |> result.map_error(fn(_e) { "delete_place_culinaries" }),
    )

    trips_db.update_place_culinaries(
      ctx |> context.with_db_conn(db_conn),
      trip_place_id,
      update_request,
    )
    |> result.map_error(fn(_e) { "update_place_culinaries" })
  })
  |> result.map_error(fn(e) { error.TransactionError(e) })
}
