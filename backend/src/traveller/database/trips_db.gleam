import gleam/string
import database/sql
import decode
import gleam/io
import gleam/list
import gleam/pgo
import gleam/result
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{type CreateTripRequest}
import traveller/database
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
        start_date:,
        end_date:,
        places_count:,
      )
    }),
  )
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
      create_trip_request.start_date,
      create_trip_request.end_date,
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
  ) = row

  use user_trip_places <- result.try(json_util.try_decode(
    places,
    trip_models.user_trip_place_decoder() |> decode.list(),
  ))

  Ok(trip_models.UserTripPlaces(
    trip_id: trip_id |> uuid.to_string,
    destination:,
    start_date:,
    end_date:,
    user_trip_places:,
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
