import frontend/events.{type AppEvent, type AppModel, AppModel}
import frontend/pages/login_page
import frontend/pages/trip_create_page
import frontend/pages/trip_details_page
import frontend/pages/trip_place_create_page
import frontend/pages/trips_dashboard_page
import frontend/routes.{type Route}
import gleam/uri.{type Uri}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_flags) -> #(AppModel, Effect(AppEvent)) {
  let initial_uri = case modem.initial_uri() {
    Ok(uri) -> uri.path |> uri.path_segments |> path_to_route
    Error(_) -> routes.Login
  }

  #(
    events.default_app_model(),
    effect.batch([
      modem.init(on_url_change),
      effect.from(fn(dispatch) { dispatch(events.OnRouteChange(initial_uri)) }),
    ]),
  )
}

fn on_url_change(uri: Uri) -> AppEvent {
  let route =
    uri.path
    |> uri.path_segments
    |> path_to_route

  events.OnRouteChange(route)
}

fn path_to_route(path_segments: List(String)) -> Route {
  case path_segments {
    ["login"] -> routes.Login
    ["signup"] -> routes.Signup
    ["dashboard"] -> routes.TripsDashboard
    ["trips", "create"] -> routes.TripCreate
    ["trips", trip_id] -> routes.TripDetails(trip_id)
    ["trips", trip_id, "places", "create"] -> routes.TripPlaceCreate(trip_id)
    _ -> routes.FourOFour
  }
}

pub fn update(model: AppModel, msg: AppEvent) -> #(AppModel, Effect(AppEvent)) {
  case msg {
    events.OnRouteChange(route) -> {
      #(AppModel(..model, route: route), case route {
        routes.TripsDashboard -> trips_dashboard_page.load_trips_dashboard()
        routes.TripDetails(trip_id) ->
          trip_details_page.load_trip_details(trip_id)
        _ -> effect.none()
      })
    }
    events.LoginPage(event) -> login_page.handle_login_page_event(model, event)
    events.TripsDashboardPage(event) ->
      trips_dashboard_page.handle_trips_dashboard_page_event(model, event)
    events.TripDetailsPage(event) ->
      trip_details_page.handle_trip_details_page_event(model, event)
    events.TripCreatePage(event) ->
      trip_create_page.handle_trip_create_page_event(model, event)
    events.TripPlaceCreatePage(event) ->
      trip_place_create_page.handle_trip_place_create_page_event(model, event)
  }
}

pub fn view(app_model: AppModel) -> Element(AppEvent) {
  html.div([], [
    html.nav([], [
      html.a([attribute.href("/dashboard")], [element.text("Trips")]),
    ]),
    html.hr([]),
    case app_model.route {
      routes.Login -> login_page.login_view(app_model)
      routes.Signup -> html.h1([], [element.text("Signup")])
      routes.TripsDashboard ->
        trips_dashboard_page.trips_dashboard_view(app_model)
      routes.TripDetails(_trip_id) ->
        trip_details_page.trip_details_view(app_model)
      routes.TripCreate -> trip_create_page.trip_create_view(app_model)
      routes.TripPlaceCreate(trip_id) ->
        trip_place_create_page.trip_place_create_view(app_model, trip_id)
      routes.FourOFour -> html.h1([], [element.text("Not Found")])
    },
    case app_model.show_loading {
      True ->
        html.div([attribute.class("loading-overlay")], [
          html.div([attribute.class("loading-screen")], [
            html.div([attribute.class("spinner")], []),
            html.p([], [element.text("Loading...")]),
          ]),
        ])
      False -> html.div([attribute.class("loading-screen-placeholder")], [])
    },
  ])
}
