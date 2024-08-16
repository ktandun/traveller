import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam_community/codec
import shared/trips
import traveller/routes/auth_routes
import traveller/trip
import traveller/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["login"] -> auth_routes.login(req, ctx)
    ["signup"] -> auth_routes.signup(req, ctx)
    ["trips"] -> trips(req, ctx)

    _ -> wisp.not_found()
  }
}

fn trips(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  use userid <- web.require_authenticated(req, ctx)

  use user_trips <- web.require_ok(trip.get_user_trips(ctx, userid))

  user_trips
  |> codec.encode_string_custom_from(trips.user_trips_codec())
  |> wisp.json_response(200)
}
