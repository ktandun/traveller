import traveller/routes/auth_routes
import traveller/routes/trip_routes
import traveller/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["login"] -> auth_routes.login(req, ctx)
    ["signup"] -> auth_routes.signup(req, ctx)
    ["trips"] -> trip_routes.trips(req, ctx)

    _ -> wisp.not_found()
  }
}
