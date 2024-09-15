import frontend/events.{type AppModel, AppModel}
import frontend/routes
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub fn simple_breadcrumb(model: AppModel) {
  html.nav([], [left_side(model), right_side(model)])
}

fn left_side(model: AppModel) {
  case model.route {
    routes.Login ->
      html.span([], [
        html.a([attribute.href("/signup")], [element.text("Signup")]),
      ])
    routes.Signup ->
      html.span([], [
        html.a([attribute.href("/login")], [element.text("Login")]),
      ])
    routes.TripDetails(trip_id)
    | routes.TripSummary(trip_id)
    | routes.TripUpdate(trip_id)
    | routes.TripPlaceCreate(trip_id)
    | routes.TripPlaceUpdate(trip_id, _trip_place_id)
    | routes.TripPlaceActivities(trip_id, _)
    | routes.TripPlaceAccomodations(trip_id, _)
    | routes.TripPlaceCulinaries(trip_id, _)
    | routes.TripCompanions(trip_id) ->
      html.span([], [
        html.a([attribute.href("/dashboard")], [element.text("Trips")]),
        element.text(" > "),
        html.a([attribute.href("/trips/" <> trip_id)], [
          element.text(model.trip_details.destination),
        ]),
      ])
    _ -> html.span([], [])
  }
}

fn right_side(model: AppModel) {
  html.span([], [
    case model.route {
      routes.Login | routes.Signup -> html.span([], [])
      _ ->
        html.a([attribute.href("#"), event.on_click(events.LogoutClicked)], [
          element.text("Logout"),
        ])
    },
  ])
}
