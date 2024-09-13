import birl
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
import traveller/context.{type Context}
import traveller/database
import traveller/date_util
import traveller/error.{type AppError}
import traveller/json_util
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
  let user_id = id.id_value(user_id)
  let trip_id = id.id_value(trip_id)

  let sql =
    "
    SELECT
        start_date,
        end_date
    FROM
        trips_view ()
    WHERE
        user_id = $1
        AND trip_id = $2;
    "

  let return_type =
    dynamic.tuple2(
      dynamic.tuple3(dynamic.int, dynamic.int, dynamic.int),
      dynamic.tuple3(dynamic.int, dynamic.int, dynamic.int),
    )

  use query_result <- result.try(
    pgo.execute(
      sql,
      ctx.db,
      [pgo.text(user_id), pgo.text(trip_id)],
      return_type,
    )
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(
    query_result,
    "get_user_trip_dates_by_trip_id",
  )

  let #(start_date, end_date) = row

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
  let user_id = id.id_value(user_id)

  let sql =
    "
    SELECT 
      create_trip (
        user_id => $1, 
        trip_id => $2, 
        destination => $3, 
        start_date => $4, 
        end_date => $5
      )
    "

  let return_type = dynamic.dynamic

  use _ <- result.try(
    pgo.execute(
      sql,
      ctx.db,
      [
        pgo.text(user_id),
        pgo.text(new_trip_id |> uuid.to_string),
        pgo.text(create_trip_request.destination),
        pgo.text(
          create_trip_request.start_date |> date_util_shared.to_yyyy_mm_dd,
        ),
        pgo.text(create_trip_request.end_date |> date_util_shared.to_yyyy_mm_dd),
      ],
      return_type,
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
  let user_id = id.id_value(user_id)
  let trip_id = id.id_value(trip_id)

  let sql =
    "
    SELECT
        count(1)
    FROM
        user_trips
    WHERE
        user_id = $1::uuid
        AND trip_id = $2::uuid
    "

  let return_type = dynamic.element(0, dynamic.int)

  use query_result <- result.try(
    pgo.execute(
      sql,
      ctx.db,
      [pgo.text(user_id), pgo.text(trip_id)],
      return_type,
    )
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "find_trip_by_trip_id")

  case row {
    1 -> Ok(Nil)
    _ ->
      Error(error.VerificationFailed(
        "User ID "
        <> user_id
        <> " Trip ID "
        <> trip_id
        <> " combination does not exist",
      ))
  }
}

pub fn ensure_trip_place_id_exists(
  ctx: Context,
  user_id: Id(UserId),
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let user_id = id.id_value(user_id)
  let trip_id = id.id_value(trip_id)
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
        count(1)
    FROM
        user_trips ut
        INNER JOIN trip_places tp ON ut.trip_id = tp.trip_id
    WHERE
        ut.user_id = $1::uuid
        AND ut.trip_id = $2::uuid
        AND tp.trip_place_id = $3::uuid
    "

  let return_type = dynamic.element(0, dynamic.int)

  use query_result <- result.try(
    pgo.execute(
      sql,
      ctx.db,
      [pgo.text(user_id), pgo.text(trip_id), pgo.text(trip_place_id)],
      return_type,
    )
    |> database.to_app_error(),
  )

  use count <- database.require_single_row(
    query_result,
    "find_trip_by_trip_place_id",
  )

  case count {
    1 -> Ok(Nil)
    _ ->
      Error(error.VerificationFailed(
        "User ID "
        <> user_id
        <> " Trip ID "
        <> trip_id
        <> " Trip Place ID "
        <> trip_place_id
        <> " combination does not exist",
      ))
  }
}

pub fn delete_user_trip_place(
  ctx: Context,
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    DELETE FROM 
      trip_places
    WHERE 
      trip_place_id = $1::uuid;
    "

  let return_type = dynamic.dynamic

  pgo.execute(sql, ctx.db, [pgo.text(trip_place_id)], return_type)
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn upsert_trip_place(
  ctx: Context,
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
  create_request: CreateTripPlaceRequest,
) -> Result(Nil, AppError) {
  let trip_id = id.id_value(trip_id)
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
      upsert_trip_place (
        trip_place_id => $1,
        trip_id => $2,
        name => $3,
        date => $4
      )
    "

  let return_type = dynamic.dynamic

  pgo.execute(
    sql,
    ctx.db,
    [
      pgo.text(trip_place_id),
      pgo.text(trip_id),
      pgo.text(create_request.place),
      pgo.text(create_request.date |> date_util_shared.to_yyyy_mm_dd),
    ],
    return_type,
  )
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn upsert_trip_companion(
  ctx: Context,
  trip_id: Id(TripId),
  upsert_request: List(TripCompanion),
) -> Result(List(Nil), AppError) {
  let trip_id = id.id_value(trip_id)

  let sql =
    "
    SELECT
      upsert_trip_companion (
        trip_companion_id => $1,
        trip_id => $2,
        name => $3,
        email => $4
      )
    "

  let return_type = dynamic.dynamic

  upsert_request
  |> list.map(fn(companion) {
    let trip_companion_id = case companion.trip_companion_id {
      "" -> ctx.uuid_provider() |> uuid.to_string
      _ -> companion.trip_companion_id
    }

    pgo.execute(
      sql,
      ctx.db,
      [
        pgo.text(trip_companion_id),
        pgo.text(trip_id),
        pgo.text(companion.name),
        pgo.text(companion.email),
      ],
      return_type,
    )
    |> result.map(fn(_) { Nil })
    |> database.to_app_error()
  })
  |> result.all
}

pub fn delete_trip_companions(
  ctx: Context,
  trip_id: Id(TripId),
) -> Result(Nil, AppError) {
  let sql =
    "
    SELECT delete_trip_companions (trip_id => $1);
    "

  let return_type = dynamic.dynamic

  pgo.execute(sql, ctx.db, [pgo.text(trip_id |> id.id_value)], return_type)
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn update_user_trip(
  ctx: Context,
  trip_id: Id(TripId),
  update_request: UpdateTripRequest,
) -> Result(Id(TripId), AppError) {
  let sql =
    "
    SELECT
      update_trip (
        trip_id => $1,
        destination => $2,
        start_date => $3,
        end_date => $4
      )
    "

  let return_type = dynamic.dynamic

  pgo.execute(
    sql,
    ctx.db,
    [
      pgo.text(trip_id |> id.id_value),
      pgo.text(update_request.destination),
      pgo.text(update_request.start_date |> date_util_shared.to_yyyy_mm_dd),
      pgo.text(update_request.end_date |> date_util_shared.to_yyyy_mm_dd),
    ],
    return_type,
  )
  |> result.map(fn(_) { trip_id })
  |> database.to_app_error()
}

pub fn get_place_activities(
  ctx: Context,
  trip_id: Id(TripId),
  trip_place_id: Id(TripPlaceId),
) -> Result(PlaceActivities, AppError) {
  let trip_id = id.id_value(trip_id)
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
        json_build_object(
          'trip_id', trip_id,
          'trip_place_id', trip_place_id,
          'place_name', place_name,
          'place_activities', place_activities
        )
    FROM
        place_activities_view ()
    WHERE
        trip_id = $1::uuid
        AND trip_place_id = $2::uuid;
    "

  let return_type = dynamic.element(0, dynamic.string)

  use query_result <- result.try(
    pgo.execute(
      sql,
      ctx.db,
      [pgo.text(trip_id), pgo.text(trip_place_id)],
      return_type,
    )
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_place_activities")

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
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    DELETE FROM place_activities
    WHERE trip_place_id = $1::uuid
    "

  let return_type = dynamic.dynamic

  pgo.execute(sql, ctx.db, [pgo.text(trip_place_id)], return_type)
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

pub fn get_place_culinaries(
  ctx: Context,
  trip_place_id: Id(TripPlaceId),
) -> Result(trip_models.PlaceCulinaries, AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
      json_build_object(
        'trip_id', trip_id,
        'trip_place_id', trip_place_id,
        'place_name', place_name,
        'place_culinaries', place_culinaries
      ) AS obj
    FROM 
      trip_place_culinaries_view ()
    WHERE 
      trip_place_id = $1
    "

  let return_type = dynamic.element(0, dynamic.string)

  use query_result <- result.try(
    pgo.execute(sql, ctx.db, [pgo.text(trip_place_id)], return_type)
    |> database.to_app_error(),
  )

  use row <- database.require_single_row(query_result, "get_place_culinaries")

  json_util.try_decode(row, trip_models_codecs.trip_place_culinaries_decoder())
}

pub fn delete_place_culinaries(
  ctx: Context,
  trip_place_id: Id(TripPlaceId),
) -> Result(Nil, AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    DELETE FROM place_culinaries pculi
    WHERE pculi.trip_place_id = $1
    "

  let return_type = dynamic.dynamic

  pgo.execute(sql, ctx.db, [pgo.text(trip_place_id)], return_type)
  |> result.map(fn(_) { Nil })
  |> database.to_app_error()
}

pub fn update_place_culinaries(
  ctx: Context,
  trip_place_id: Id(TripPlaceId),
  update_request: trip_models.PlaceCulinaries,
) -> Result(Nil, AppError) {
  let trip_place_id = id.id_value(trip_place_id)

  let sql =
    "
    SELECT
      upsert_place_culinary (
        trip_place_id => $1, 
        place_culinary_id => $2, 
        name => $3, 
        information_url => $4, 
        open_time => $5, 
        close_time => $6)
    "

  let return_type = dynamic.dynamic

  update_request.place_culinaries
  |> list.map(fn(culinary) {
    let place_culinary_id = case string.is_empty(culinary.place_culinary_id) {
      True -> ctx.uuid_provider() |> uuid.to_string
      False -> culinary.place_culinary_id
    }

    pgo.execute(
      sql,
      ctx.db,
      [
        pgo.text(trip_place_id),
        pgo.text(place_culinary_id),
        pgo.text(culinary.name),
        pgo.nullable(pgo.text, culinary.information_url),
        pgo.nullable(pgo.text, culinary.open_time),
        pgo.nullable(pgo.text, culinary.close_time),
      ],
      return_type,
    )
    |> database.to_app_error()
  })
  |> result.all
  |> result.map(fn(_) { Nil })
}
