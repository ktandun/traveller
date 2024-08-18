import gleam/http
import shared/id
import traveller/routes/auth_routes
import traveller/routes/trip_routes
import traveller/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["login"] ->
      case req.method {
        http.Post -> auth_routes.handle_login(req, ctx)
        _ -> wisp.method_not_allowed([http.Post])
      }
    ["signup"] ->
      case req.method {
        http.Post -> auth_routes.handle_signup(req, ctx)
        _ -> wisp.method_not_allowed([http.Post])
      }
    ["trips"] ->
      case req.method {
        http.Get -> trip_routes.handle_get_trips(req, ctx)
        http.Post -> trip_routes.handle_create_trip(req, ctx)
        _ -> wisp.method_not_allowed([http.Get, http.Post])
      }
    ["trips", trip_id, "places"] ->
      case req.method {
        http.Get ->
          trip_routes.handle_get_trip_places(req, ctx, id.to_id(trip_id))
        _ -> wisp.method_not_allowed([http.Get])
      }

    _ -> wisp.not_found()
  }
}
