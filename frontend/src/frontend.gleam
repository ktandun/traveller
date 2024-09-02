import frontend/api
import frontend/breadcrumb
import frontend/events.{type AppEvent, type AppModel, AppModel}
import frontend/loading_spinner
import frontend/pages/login_page
import frontend/pages/trip_companions_page
import frontend/pages/trip_create_page
import frontend/pages/trip_details_page
import frontend/pages/trip_place_create_page
import frontend/pages/trip_place_details_page
import frontend/pages/trip_update_page
import frontend/pages/trips_dashboard_page
import frontend/routes.{type Route}
import frontend/toast
import gleam/io
import gleam/string
import gleam/uri.{type Uri}
import lustre
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

// Defines all the routes in this app
fn path_to_route(path_segments: List(String)) -> Route {
  case path_segments {
    ["index.html"] -> routes.TripsDashboard
    ["login"] -> routes.Login
    ["dashboard"] -> routes.TripsDashboard
    ["trips", "create"] -> routes.TripCreate
    ["trips", trip_id] -> routes.TripDetails(trip_id)
    ["trips", trip_id, "update"] -> routes.TripUpdate(trip_id)
    ["trips", trip_id, "add-companions"] -> routes.TripCompanions(trip_id)
    ["trips", trip_id, "places", "create"] -> routes.TripPlaceCreate(trip_id)
    ["trips", trip_id, "places", trip_place_id] ->
      routes.TripPlaceDetails(trip_id, trip_place_id)
    _ -> routes.FourOFour
  }
}

// Root handler for all the events in the app
pub fn update(model: AppModel, msg: AppEvent) -> #(AppModel, Effect(AppEvent)) {
  io.debug(msg)
  case msg {
    // Handle page-specific on-load events
    events.OnRouteChange(route) -> #(AppModel(..model, route:), case route {
      routes.TripsDashboard -> api.send_get_user_trips_request()
      routes.TripPlaceCreate(trip_id)
      | routes.TripPlaceDetails(trip_id, _trip_place_id)
      | routes.TripCompanions(trip_id)
      | routes.TripUpdate(trip_id) ->
        case string.is_empty(model.trip_details.destination) {
          True -> api.send_get_trip_details_request(trip_id)
          False -> effect.none()
        }
      routes.TripDetails(trip_id) -> api.send_get_trip_details_request(trip_id)
      _ -> effect.none()
    })

    events.ShowToast -> toast.show_toast(model)
    events.HideToast -> toast.hide_toast(model)

    // Let the children pages handle their page-sepcific events
    events.LoginPage(event) -> login_page.handle_login_page_event(model, event)
    events.TripsDashboardPage(event) ->
      trips_dashboard_page.handle_trips_dashboard_page_event(model, event)
    events.TripDetailsPage(event) ->
      trip_details_page.handle_trip_details_page_event(model, event)
    events.TripCreatePage(event) ->
      trip_create_page.handle_trip_create_page_event(model, event)
    events.TripUpdatePage(event) ->
      trip_update_page.handle_trip_update_page_event(model, event)
    events.TripPlaceCreatePage(event) ->
      trip_place_create_page.handle_trip_place_create_page_event(model, event)
    events.TripCompanionsPage(event) ->
      trip_companions_page.handle_trip_companions_page_event(model, event)

    events.NoEvent -> #(model, effect.none())
  }
}

pub fn view(model: AppModel) -> Element(AppEvent) {
  html.div([], [
    breadcrumb.simple_breadcrumb(model),
    html.hr([]),
    // Global toast view
    toast.simple_toast(
      model.toast.visible,
      model.toast.header,
      model.toast.content,
    ),
    // Global loading spinner
    loading_spinner.simple_loading_spinner(model),
    // Route specific views
    case model.route {
      routes.Login -> login_page.login_view(model)
      routes.Signup -> html.h1([], [element.text("Signup")])
      routes.TripsDashboard -> trips_dashboard_page.trips_dashboard_view(model)
      routes.TripDetails(_trip_id) -> trip_details_page.trip_details_view(model)
      routes.TripPlaceDetails(trip_id, trip_place_id) ->
        trip_place_details_page.trip_place_details_view(
          model,
          trip_id,
          trip_place_id,
        )
      routes.TripCompanions(trip_id) ->
        trip_companions_page.trip_companions_view(model, trip_id)
      routes.TripCreate -> trip_create_page.trip_create_view(model)
      routes.TripUpdate(trip_id) ->
        trip_update_page.trip_update_view(model, trip_id)
      routes.TripPlaceCreate(trip_id) ->
        trip_place_create_page.trip_place_create_view(model, trip_id)
      routes.FourOFour -> html.h1([], [element.text("Not Found")])
    },
  ])
}
