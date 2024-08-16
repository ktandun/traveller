import gleam/http.{Get, Post}
import gleam/io
import gleam/list
import gleam/pgo
import gleam/result
import gleam_community/codec
import shared/id.{type Id, type TripId, type UserId}
import shared/trips.{type CreateTripRequest}
import traveller/database
import traveller/error.{type AppError}
import traveller/json_util
import traveller/sql
import traveller/web.{type Context}
import wisp.{type Request, type Response}
import youid/uuid

// Public functions ------------------------------------------

pub fn handle_trips(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> handle_get_trips(req, ctx)
    Post -> handle_create_trip(req, ctx)
    _ -> wisp.not_found()
  }
}

// Private functions -----------------------------------------

fn handle_get_trips(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  use user_id <- web.require_authenticated(req, ctx)

  use user_trips <- web.require_ok(get_user_trips(ctx, user_id))

  user_trips
  |> codec.encode_string_custom_from(trips.user_trips_codec())
  |> wisp.json_response(200)
}

fn handle_create_trip(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use json <- wisp.require_string_body(req)
  use user_id <- web.require_authenticated(req, ctx)

  let response = {
    use create_trip_request <- result.try(json_util.try_decode(
      json,
      trips.create_trip_request_codec(),
    ))

    create_user_trip(ctx, user_id, create_trip_request)
  }

  use trip_id <- web.require_ok(response)

  trip_id
  |> codec.encode_string_custom_from(id.id_codec())
  |> wisp.json_response(200)
}

fn get_user_trips(
  ctx: Context,
  user_id: Id(UserId),
) -> Result(trips.UserTrips, AppError) {
  let user_id = id.id_value(user_id)

  use pgo.Returned(_, rows) <- result.map(
    sql.get_user_trips(ctx.db, user_id)
    |> database.map_error(),
  )

  trips.UserTrips(
    user_trips: rows
    |> list.map(fn(row) { trips.UserTrip(destination: row.destination) }),
  )
}

fn create_user_trip(
  ctx: Context,
  user_id: Id(UserId),
  create_trip_request: CreateTripRequest,
) -> Result(Id(TripId), AppError) {
  let new_trip_id = ctx.uuid_provider()
  let assert Ok(trip_id) = uuid.from_string(new_trip_id)
  let assert Ok(user_id) = uuid.from_string(id.id_value(user_id))

  use pgo.Returned(_, _) <- result.try(
    sql.create_trip(ctx.db, trip_id, create_trip_request.destination)
    |> database.map_error(),
  )

  use pgo.Returned(_, _) <- result.try(
    sql.create_user_trip(ctx.db, user_id, trip_id)
    |> database.map_error(),
  )

  Ok(id.to_trip_id(new_trip_id))
}
