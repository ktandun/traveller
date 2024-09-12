import frontend/events.{type AppModel, AppModel}
import frontend/routes
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn simple_breadcrumb(model: AppModel) {
  html.nav([], [
    html.a([attribute.href("/dashboard")], [element.text("Trips")]),
    case model.route {
      routes.TripDetails(trip_id)
      | routes.TripUpdate(trip_id)
      | routes.TripPlaceCreate(trip_id)
      | routes.TripPlaceActivities(trip_id, _)
      | routes.TripPlaceAccomodations(trip_id, _)
      | routes.TripPlaceCulinaries(trip_id, _)
      | routes.TripCompanions(trip_id) ->
        html.span([], [
          element.text(" > "),
          html.a([attribute.href("/trips/" <> trip_id)], [
            element.text(model.trip_details.destination),
          ]),
        ])
      _ -> html.span([], [])
    },
  ])
}
