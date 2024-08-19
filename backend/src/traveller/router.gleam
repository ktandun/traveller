import gleam/http
import gleam/json
import gleam/result
import gleam/string_builder
import shared/auth
import shared/constants
import shared/id.{type Id, type TripId, type UserId}
import shared/trips
import traveller/error
import traveller/json_util
import traveller/routes/auth_routes
import traveller/routes/trip_routes
import traveller/web.{type Context}
import wisp.{type Request, type Response}
import youid/uuid

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["login"] -> {
      case req.method {
        http.Post -> post_login(req, ctx)
        _ -> wisp.method_not_allowed([http.Post])
      }
    }
    ["signup"] -> {
      case req.method {
        http.Post -> post_signup(req, ctx)
        _ -> wisp.method_not_allowed([http.Post])
      }
    }
    ["trips"] -> {
      use user_id <- web.require_authenticated(req, ctx)

      case req.method {
        http.Get -> get_trips(req, ctx, user_id)
        http.Post -> post_trips(req, ctx, user_id)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }
    }
    ["trips", trip_id, "places"] -> {
      use user_id <- web.require_authenticated(req, ctx)

      case req.method {
        http.Get -> get_trips_places(req, ctx, user_id, trip_id)
        _ -> wisp.method_not_allowed([http.Get])
      }
    }

    _ -> wisp.not_found()
  }
}

fn post_login(req: Request, ctx: Context) {
  use request_body <- wisp.require_string_body(req)
  use login_request <- web.require_valid_json(json_util.try_decode(
    request_body,
    auth.login_request_decoder(),
  ))

  use user_id <- web.require_ok(auth_routes.handle_login(ctx, login_request))

  user_id
  |> id.id_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
  |> wisp.set_cookie(
    req,
    constants.cookie,
    uuid.to_string(id.id_value(user_id)),
    wisp.Signed,
    60 * 60 * 24,
  )
}

fn post_signup(req: Request, ctx: Context) {
  use request_body <- wisp.require_string_body(req)
  use signup_request <- web.require_valid_json(json_util.try_decode(
    request_body,
    auth.signup_request_decoder(),
  ))

  use user_id <- web.require_ok(auth_routes.handle_signup(ctx, signup_request))

  user_id
  |> id.id_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
}

fn get_trips(_req: Request, ctx: Context, user_id: Id(UserId)) {
  use user_trips <- web.require_ok(trip_routes.handle_get_trips(ctx, user_id))

  user_trips
  |> trips.user_trips_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
}

fn post_trips(req: Request, ctx: Context, user_id: Id(UserId)) {
  use request_body <- wisp.require_string_body(req)
  use create_trip_request <- web.require_valid_json(json_util.try_decode(
    request_body,
    trips.create_trip_request_decoder(),
  ))

  use trip_id <- web.require_ok(trip_routes.handle_create_trip(
    ctx,
    user_id,
    create_trip_request,
  ))

  trip_id
  |> id.id_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
}

fn get_trips_places(
  _req: Request,
  ctx: Context,
  user_id: Id(UserId),
  trip_id: String,
) {
  use trip_id <- web.require_ok(
    id.to_id(trip_id)
    |> result.map_error(fn(err) { error.InvalidUUIDString(err) }),
  )

  use user_trip_places <- web.require_ok(trip_routes.handle_get_trip_places(
    ctx,
    user_id,
    trip_id,
  ))

  user_trip_places
  |> trips.user_trip_places_encoder
  |> json.to_string_builder
  |> wisp.json_response(200)
}
