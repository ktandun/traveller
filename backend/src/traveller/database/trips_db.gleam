import birl
import database/sql
import gleam/dynamic
import gleam/list
import gleam/option.{type Option}
import gleam/pgo
import gleam/result
import gleam/string
import shared/date_util_shared
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{
  type CreateTripPlaceRequest, type CreateTripRequest, type PlaceActivities,
  type TripCompanion, type UpdateTripRequest,
}
import shared/trip_models_codecs
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
  let user_id = id.id_value(user_id)

  let sql =
    "
    SELECT
      json_build_object('user_trips',
        json_agg(
          json_build_object(
            'trip_id', trip_id,
            'destination', destination,
            'start_date', start_date,
            'end_date', end_date
          )
        ) 
      ) AS result
    FROM
        trips_view ()
    WHERE
        user_id = $1::uuid
    GROUP BY 
        user_id
    "

  let return_type = dynamic.element(0, dynamic.string)

  use query_result <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(user_id)], return_type)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_user_trips")

  json_util.try_decode(row, trip_models.user_trips_decoder())
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
  let user_id = user_id |> id.id_value
  let trip_id = trip_id |> id.id_value

  let sql =
    "
    SELECT
      json_build_object(
        'trip_id', trip_id,
        'destination', destination,
        'start_date', start_date,
        'end_date', end_date,
        'total_activities_fee', total_activities_fee,
        'total_accomodations_fee', total_accomodations_fee,
        'user_trip_places', places,
        'user_trip_companions', companions
      ) AS result
    FROM
        trips_view ()
    WHERE
        user_id = $1::uuid
        AND trip_id = $2::uuid;
    "

  let return_type = dynamic.element(0, dynamic.string)

  use query_result <- result.try(
    pgo.execute(
      sql,
      ctx.db,
      [pgo.text(user_id), pgo.text(trip_id)],
      return_type,
    )
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_user_trip_places")

  json_util.try_decode(row, trip_models.user_trip_places_decoder())
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

pub fn ensure_trip_place_id_exists(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let user_id = uuid_util.from_string(id.id_value(user_id))
  let trip_id = uuid_util.from_string(id.id_value(trip_id))
  let trip_place_id = uuid_util.from_string(id.id_value(trip_place_id))

  use query_result <- result.try(
    sql.find_trip_by_trip_place_id(ctx.db, user_id, trip_id, trip_place_id)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(
    query_result,
    "find_trip_by_trip_place_id",
  )

  let sql.FindTripByTripPlaceIdRow(row) = row

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

pub fn get_place_activities(
  ctx: Context,
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(PlaceActivities, AppError) {
  let trip_id = uuid_util.from_string(id.id_value(trip_id))
  let trip_place_id = uuid_util.from_string(id.id_value(trip_place_id))

  use query_result <- result.try(
    sql.get_place_activities(ctx.db, trip_id, trip_place_id)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_place_activities")

  let sql.GetPlaceActivitiesRow(row) = row

  use place_activities <- result.try(json_util.try_decode(
    row,
    trip_models_codecs.place_activities_decoder(),
  ))

  Ok(place_activities)
}

pub fn create_place_activities(
  ctx: Context,
  _trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
  update_request: trip_models.PlaceActivities,
) -> Result(List(Nil), AppError) {
  let sql =
    "
    SELECT create_place_activity (
      place_activity_id => $1,
      trip_place_id => $2,
      name => $3,
      information_url => $4,
      start_time => $5,
      end_time => $6,
      entry_fee => $7)"

  let return_type = dynamic.dynamic

  update_request.place_activities
  |> list.map(fn(activity) {
    pgo.execute(
      sql,
      ctx.db,
      [
        pgo.text(activity.place_activity_id),
        pgo.text(trip_place_id |> id.id_value),
        pgo.text(activity.name),
        pgo.nullable(pgo.text, activity.information_url),
        pgo.nullable(pgo.text, activity.start_time),
        pgo.nullable(pgo.text, activity.end_time),
        pgo.nullable(pgo.float, activity.entry_fee),
      ],
      return_type,
    )
    |> result.map(fn(_) { Nil })
    |> database.to_app_error()
  })
  |> result.all
}

pub fn delete_place_activities(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let user_id = uuid_util.from_string(id.id_value(user_id))
  let trip_id = uuid_util.from_string(id.id_value(trip_id))
  let trip_place_id = uuid_util.from_string(id.id_value(trip_place_id))

  sql.delete_place_activities(ctx.db, user_id, trip_id, trip_place_id)
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn get_place_accomodation(
  ctx: Context,
  trip_place_id: Id(TripPlaceId),
) -> Result(Option(trip_models.PlaceAccomodation), AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
      json_build_object(
        'place_accomodation_id', place_accomodation_id,
        'place_name', place_name,
        'accomodation_name', accomodation_name,
        'information_url', information_url,
        'accomodation_fee', accomodation_fee,
        'paid', paid
      )
    FROM 
        trip_place_accomodations_view ()
    WHERE 
        trip_place_id = $1"

  let return_type = dynamic.element(0, dynamic.string)

  use pgo.Returned(_, rows) <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(trip_place_id)], return_type)
    |> database.to_app_error(),
  )

  case rows {
    [] -> Ok(option.None)
    _ -> {
      let assert [row, ..] = rows

      json_util.try_decode(row, trip_models_codecs.place_accomodation_decoder())
      |> result.map(fn(r) { option.Some(r) })
    }
  }
}

pub fn update_place_accomodation(
  ctx: Context,
  trip_place_id: Id(TripPlaceId),
  update_request: trip_models.PlaceAccomodation,
) -> Result(Nil, AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
      upsert_place_accomodation(
        trip_place_id => $1,
        place_accomodation_id => $2,
        accomodation_name => $3,
        information_url => $4,
        accomodation_fee => $5,
        paid => $6
      );"

  let return_type = dynamic.dynamic

  pgo.execute(
    sql,
    ctx.db,
    [
      pgo.text(trip_place_id),
      pgo.text(case string.is_empty(update_request.place_accomodation_id) {
        True -> ctx.uuid_provider() |> uuid.to_string
        False -> update_request.place_accomodation_id
      }),
      pgo.text(update_request.accomodation_name),
      pgo.nullable(pgo.text, update_request.information_url),
      pgo.nullable(pgo.float, update_request.accomodation_fee),
      pgo.bool(update_request.paid),
    ],
    return_type,
  )
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}
