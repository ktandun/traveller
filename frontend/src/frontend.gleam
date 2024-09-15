import frontend/api
import frontend/breadcrumb
import frontend/events.{type AppEvent, type AppModel, AppModel}
import frontend/pages/error_500
import frontend/pages/login_page
import frontend/pages/signup_page
import frontend/pages/trip_companions_page
import frontend/pages/trip_create_page
import frontend/pages/trip_details_page
import frontend/pages/trip_place_accomodations_page
import frontend/pages/trip_place_activities_page
import frontend/pages/trip_place_create_page
import frontend/pages/trip_place_culinaries_page
import frontend/pages/trip_place_update_page
import frontend/pages/trip_update_page
import frontend/pages/trips_dashboard_page
import frontend/routes.{type Route}
import frontend/toast
import gleam/option
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
    [] -> routes.TripsDashboard
    ["500"] -> routes.ErrorFiveHundred
    ["login"] -> routes.Login
    ["signup"] -> routes.Signup
    ["dashboard"] -> routes.TripsDashboard
    ["trips", "create"] -> routes.TripCreate
    ["trips", trip_id] -> routes.TripDetails(trip_id)
    ["trips", trip_id, "update"] -> routes.TripUpdate(trip_id)
    ["trips", trip_id, "add-companions"] -> routes.TripCompanions(trip_id)
    ["trips", trip_id, "places", "create"] -> routes.TripPlaceCreate(trip_id)
    ["trips", trip_id, "places", trip_place_id, "update"] ->
      routes.TripPlaceUpdate(trip_id, trip_place_id)
    ["trips", trip_id, "places", trip_place_id, "activities"] ->
      routes.TripPlaceActivities(trip_id, trip_place_id)
    ["trips", trip_id, "places", trip_place_id, "accomodations"] ->
      routes.TripPlaceAccomodations(trip_id, trip_place_id)
    ["trips", trip_id, "places", trip_place_id, "culinaries"] ->
      routes.TripPlaceCulinaries(trip_id, trip_place_id)
    _ -> routes.FourOFour
  }
}

fn load_trip_details(model: AppModel, trip_id: String) {
  case string.is_empty(model.trip_details.destination) {
    True -> api.send_get_trip_details_request(trip_id)
    False -> effect.none()
  }
}

// Root handler for all the events in the app
pub fn update(model: AppModel, msg: AppEvent) -> #(AppModel, Effect(AppEvent)) {
  case msg {
    // Handle page-specific on-load events
    events.OnRouteChange(route) -> #(AppModel(..model, route:), case route {
      routes.TripsDashboard -> api.send_get_user_trips_request()
      routes.TripPlaceUpdate(trip_id, _) ->
        effect.batch([
          load_trip_details(model, trip_id),
          effect.from(fn(dispatch) {
            dispatch(events.TripPlaceUpdatePage(
              events.TripPlaceUpdatePageOnLoad,
            ))
          }),
        ])
      routes.TripPlaceCreate(trip_id)
      | routes.TripCompanions(trip_id)
      | routes.TripUpdate(trip_id) -> load_trip_details(model, trip_id)
      routes.TripDetails(trip_id) -> api.send_get_trip_details_request(trip_id)
      routes.TripPlaceActivities(trip_id, trip_place_id) ->
        effect.batch([
          load_trip_details(model, trip_id),
          api.send_get_place_activities_request(trip_id, trip_place_id),
        ])
      routes.TripPlaceAccomodations(trip_id, trip_place_id) ->
        effect.batch([
          load_trip_details(model, trip_id),
          api.send_get_place_accomodation_request(trip_id, trip_place_id),
        ])
      routes.TripPlaceCulinaries(trip_id, trip_place_id) ->
        effect.batch([
          load_trip_details(model, trip_id),
          api.send_get_place_culinaries_request(trip_id, trip_place_id),
        ])
      _ -> effect.none()
    })

    events.ShowToast -> toast.show_toast(model)
    events.HideToast -> toast.hide_toast(model)

    events.LogoutClicked -> #(model, api.send_logout_request())
    events.LogoutApiReturnedResponse -> #(
      model,
      modem.push("/login", option.None, option.None),
    )

    // Let the children pages handle their page-sepcific events
    events.LoginPage(event) -> login_page.handle_login_page_event(model, event)
    events.SignupPage(event) ->
      signup_page.handle_signup_page_event(model, event)
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
    events.TripPlaceUpdatePage(event) ->
      trip_place_update_page.handle_trip_place_update_page_event(model, event)
    events.TripCompanionsPage(event) ->
      trip_companions_page.handle_trip_companions_page_event(model, event)
    events.TripPlaceActivitiesPage(event) ->
      trip_place_activities_page.handle_trip_place_activities_page_event(
        model,
        event,
      )
    events.TripPlaceAccomodationPage(event) ->
      trip_place_accomodations_page.handle_trip_place_accomodations_page_event(
        model,
        event,
      )
    events.TripPlaceCulinariesPage(event) ->
      trip_place_culinaries_page.handle_trip_place_culinaries_page_event(
        model,
        event,
      )

    events.NoEvent -> #(model, effect.none())
  }
}

pub fn view(model: AppModel) -> Element(AppEvent) {
  html.div([], [
    breadcrumb.simple_breadcrumb(model),
    // Global toast view
    toast.simple_toast(
      model.toast.visible,
      model.toast.header,
      model.toast.content,
      model.toast.status,
    ),
    // Global loading spinner
    //loading_spinner.simple_loading_spinner(model),
    // Route specific views
    case model.route {
      routes.ErrorFiveHundred -> error_500.error_five_hundred()
      routes.Login -> login_page.login_view(model)
      routes.Signup -> signup_page.signup_view(model)
      routes.TripsDashboard -> trips_dashboard_page.trips_dashboard_view(model)
      routes.TripDetails(_trip_id) -> trip_details_page.trip_details_view(model)
      routes.TripPlaceUpdate(trip_id, trip_place_id) ->
        trip_place_update_page.trip_place_update_view(
          model,
          trip_id,
          trip_place_id,
        )
      routes.TripPlaceActivities(trip_id, trip_place_id) ->
        trip_place_activities_page.trip_place_activities_view(
          model,
          trip_id,
          trip_place_id,
        )
      routes.TripPlaceAccomodations(trip_id, trip_place_id) ->
        trip_place_accomodations_page.trip_place_accomodations_view(
          model,
          trip_id,
          trip_place_id,
        )
      routes.TripPlaceCulinaries(trip_id, trip_place_id) ->
        trip_place_culinaries_page.trip_place_culinaries_view(
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
