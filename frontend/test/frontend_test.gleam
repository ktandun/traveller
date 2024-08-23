import birdie
import frontend
import frontend/events
import frontend/routes
import gleeunit
import gleeunit/should
import lustre/element
import shared/auth_models

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn route_change_to_login_test() {
  let init =
    events.AppModel(
      route: routes.Signup,
      login_request: auth_models.default_login_request(),
    )

  let #(model, _) = frontend.update(init, events.OnRouteChange(routes.Login))

  frontend.view(model)
  |> element.to_string
  |> birdie.snap("route change to login")
}
