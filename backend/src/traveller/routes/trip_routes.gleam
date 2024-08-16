import gleam/http.{Get, Post}
import gleam_community/codec
import shared/trips
import traveller/trip
import traveller/web.{type Context}
import wisp.{type Request, type Response}

pub fn trips(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> get_trips(req, ctx)
    Post -> create_trip(req, ctx)
    _ -> wisp.not_found()
  }
}

fn get_trips(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  use userid <- web.require_authenticated(req, ctx)

  use user_trips <- web.require_ok(trip.get_user_trips(ctx.db, userid))

  user_trips
  |> codec.encode_string_custom_from(trips.user_trips_codec())
  |> wisp.json_response(200)
}

fn create_trip(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)
  use user_id <- web.require_authenticated(req, ctx)

  let assert Ok(trip_id) = trip.create_user_trip(ctx.db, ctx.uuid_provider, user_id)

  trip_id
  |> codec.encode_string_custom_from(trips.trip_id_codec())
  |> wisp.json_response(200)
}
