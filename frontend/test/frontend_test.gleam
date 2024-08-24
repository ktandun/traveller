import birdie
import frontend
import frontend/events
import frontend/routes
import gleeunit
import gleeunit/should
import lustre/element

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn route_change_to_login_test() {
  let init = events.default_app_model()

  let #(model, _) = frontend.update(init, events.OnRouteChange(routes.Login))

  frontend.view(model)
  |> element.to_string
  |> birdie.snap("route change to login")
}
