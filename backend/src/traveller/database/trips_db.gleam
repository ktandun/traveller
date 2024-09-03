import birl
import database/sql
import gleam/list
import gleam/option
import gleam/pgo
import gleam/result
import gleam/string
import shared/date_util_shared
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{
  type CreateTripPlaceRequest, type CreateTripRequest, type TripCompanion,
  type UpdateTripRequest,
}
import toy
import traveller/database
import traveller/date_util
import traveller/error.{type AppError}
import traveller/json_util
import traveller/uuid_util
import traveller/web.{type Context}
import youid/uuid

pub fn get_user_trips(
  ctx: Context,
  user_id: Id(UserId),
) -> Result(trip_models.UserTrips, AppError) {
  let user_id = uuid_util.from_string(id.id_value(user_id))

  use pgo.Returned(_, rows) <- result.map(
    sql.get_user_trips(ctx.db, user_id)
    |> database.to_app_error(),
  )

  trip_models.UserTrips(
    user_trips: rows
    |> list.map(fn(row) {
      let sql.GetUserTripsRow(
        trip_id,
        destination,
        start_date,
        end_date,
        places_count,
      ) = row
      trip_models.UserTrip(
        trip_id: trip_id,
        destination:,
        start_date: date_util.from_date_tuple(start_date),
        end_date: date_util.from_date_tuple(end_date),
        places_count:,
      )
    }),
  )
}

pub fn get_user_trip_dates_by_trip_id(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(#(birl.Day, birl.Day), AppError) {
  let user_id = uuid_util.from_string(id.id_value(user_id))
  let trip_id = uuid_util.from_string(id.id_value(trip_id))

  use query_result <- result.try(
    sql.get_user_trip_dates_by_trip_id(ctx.db, user_id, trip_id)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(
    query_result,
    "get_user_trip_dates_by_trip_id",
  )

  let sql.GetUserTripDatesByTripIdRow(start_date, end_date) = row

  Ok(#(
    start_date |> date_util.from_date_tuple,
    end_date |> date_util.from_date_tuple,
  ))
}

pub fn create_user_trip(
  ctx: Context,
  user_id: Id(UserId),
  create_trip_request: CreateTripRequest,
) -> Result(Id(TripId), AppError) {
  let new_trip_id = ctx.uuid_provider()
  let user_id = uuid_util.from_string(id.id_value(user_id))

  use pgo.Returned(_, _) <- result.try(
    sql.create_trip(
      ctx.db,
      user_id |> uuid.to_string,
      new_trip_id |> uuid.to_string,
      create_trip_request.destination,
      create_trip_request.start_date |> date_util_shared.to_yyyy_mm_dd,
      create_trip_request.end_date |> date_util_shared.to_yyyy_mm_dd,
    )
    |> database.to_app_error(),
  )

  new_trip_id
  |> uuid.to_string
  |> id.to_id
  |> Ok
}

pub fn get_user_trip_places(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(trip_models.UserTripPlaces, AppError) {
  let user_id = user_id |> id.id_value |> uuid_util.from_string
  let trip_id = trip_id |> id.id_value |> uuid_util.from_string

  use query_result <- result.try(
    sql.get_user_trip_places(ctx.db, user_id, trip_id)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_user_trip_places")

  let sql.GetUserTripPlacesRow(
    trip_id,
    destination,
    start_date,
    end_date,
    places,
    companions,
  ) = row

  use user_trip_places <- result.try(json_util.try_decode(
    places,
    toy.list(trip_models.user_trip_place_decoder()),
  ))

  use user_trip_companions <- result.try(json_util.try_decode(
    companions,
    toy.list(trip_models.user_trip_companion_decoder()),
  ))

  Ok(trip_models.UserTripPlaces(
    trip_id: trip_id |> uuid.to_string,
    destination:,
    start_date: start_date |> date_util.from_date_tuple,
    end_date: end_date |> date_util.from_date_tuple,
    user_trip_places:,
    user_trip_companions:,
  ))
}

pub fn ensure_trip_id_exists(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
) -> Result(Nil, AppError) {
  let user_id = uuid_util.from_string(id.id_value(user_id))
  let trip_id = uuid_util.from_string(id.id_value(trip_id))

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

pub fn delete_user_trip_place(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let user_id = uuid_util.from_string(id.id_value(user_id))
  let trip_id = uuid_util.from_string(id.id_value(trip_id))
  let trip_place_id = uuid_util.from_string(id.id_value(trip_place_id))

  sql.delete_trip_place(ctx.db, user_id, trip_id, trip_place_id)
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn upsert_trip_place(
  ctx: Context,
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
  request: CreateTripPlaceRequest,
) -> Result(Nil, AppError) {
  let trip_id = id.id_value(trip_id)
  let trip_place_id = id.id_value(trip_place_id)

  sql.upsert_trip_place(
    ctx.db,
    trip_place_id,
    trip_id,
    request.place,
    request.date |> date_util_shared.to_yyyy_mm_dd,
    request.google_maps_link |> option.unwrap(""),
  )
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn upsert_trip_companion(
  ctx: Context,
  trip_id: Id(TripId),
  request: List(TripCompanion),
) -> Result(List(Nil), AppError) {
  let trip_id = id.id_value(trip_id)

  request
  |> list.map(fn(companion) {
    let trip_companion_id = case string.is_empty(companion.trip_companion_id) {
      True -> ctx.uuid_provider() |> uuid.to_string
      False -> companion.trip_companion_id
    }

    sql.upsert_trip_companion(
      ctx.db,
      trip_companion_id,
      trip_id,
      companion.name |> string.trim,
      companion.email |> string.trim,
    )
    |> result.map(fn(_) { Nil })
    |> database.to_app_error()
  })
  |> result.all
}

pub fn delete_trip_companions(ctx: Context, trip_id: Id(TripId)) {
  let trip_id = id.id_value(trip_id)

  sql.delete_trip_companions(ctx.db, trip_id)
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn update_user_trip(
  ctx: Context,
  trip_id: Id(TripId),
  update_trip_request: UpdateTripRequest,
) -> Result(Id(TripId), AppError) {
  use pgo.Returned(_, _) <- result.try(
    sql.update_trip(
      ctx.db,
      trip_id |> id.id_value,
      update_trip_request.destination,
      update_trip_request.start_date |> date_util_shared.to_yyyy_mm_dd,
      update_trip_request.end_date |> date_util_shared.to_yyyy_mm_dd,
    )
    |> database.to_app_error(),
  )

  trip_id
  |> Ok
}
