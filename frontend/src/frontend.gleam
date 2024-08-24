import frontend/events.{type AppEvent, type AppModel, AppModel}
import frontend/pages/login_page
import frontend/pages/trips_dashboard_page
import frontend/routes
import gleam/io
import gleam/uri.{type Uri}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import shared/auth_models

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(flags) -> #(AppModel, Effect(AppEvent)) {
  let initial_uri = case modem.initial_uri() {
    Ok(uri) -> routes.TripsDashboard
    Error(_) -> routes.Login
  }

  io.debug(flags)
  #(
    AppModel(
      route: routes.Login,
      login_request: auth_models.default_login_request(),
    ),
    modem.init(on_url_change),
  )
}

fn on_url_change(uri: Uri) -> AppEvent {
  case uri.path_segments(uri.path) {
    ["login"] -> events.OnRouteChange(routes.Login)
    ["signup"] -> events.OnRouteChange(routes.Signup)
    ["dashboard"] -> events.OnRouteChange(routes.TripsDashboard)
    _ -> events.OnRouteChange(routes.FourOFour)
  }
}

pub fn update(model: AppModel, msg: AppEvent) -> #(AppModel, Effect(AppEvent)) {
  case msg {
    events.OnRouteChange(route) -> #(
      AppModel(..model, route: route),
      effect.none(),
    )
    events.LoginPage(event) -> login_page.handle_login_page_event(model, event)
  }
}

pub fn view(app_model: AppModel) -> Element(AppEvent) {
  html.div([], [
    html.nav([], [
      html.a([attribute.href("/login")], [element.text("Go to login")]),
      html.a([attribute.href("/signup")], [element.text("Go to signup")]),
    ]),
    case app_model.route {
      routes.Login -> login_page.login_view(app_model)
      routes.Signup -> html.h1([], [element.text("Signup")])
      routes.TripsDashboard ->
        trips_dashboard_page.trips_dashboard_view(app_model)
      routes.FourOFour -> html.h1([], [element.text("Not Found")])
    },
  ])
}
