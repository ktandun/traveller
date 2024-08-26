import decode
import frontend/events.{
  type AppEvent, type AppModel, type TripsDashboardPageEvent, AppModel,
}
import frontend/routes
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import modem
import shared/trip_models

pub fn trips_dashboard_view(app_model: AppModel) {
  html.div([], [
    html.h1([], [
      element.text("Planned"),
      html.span([attribute.class("text-cursive")], [element.text(" Trips 🌴")]),
    ]),
    html.button(
      [
        event.on_click(events.TripsDashboardPage(
          events.TripsDashboardPageUserClickedCreateTripButton,
        )),
      ],
      [element.text("Create Trip")],
    ),
    html.table([], [
      html.thead([], [
        html.tr([], [
          html.th([], [element.text("Destination")]),
          html.th([], [element.text("From")]),
          html.th([], [element.text("Until")]),
          html.th([], [element.text("Number of places")]),
        ]),
      ]),
      html.tbody(
        [],
        app_model.trips_dashboard.user_trips
          |> list.map(fn(user_trip) {
            html.tr([], [
              html.td([], [
                html.a([attribute.href("trips/" <> user_trip.trip_id)], [
                  element.text(user_trip.destination),
                ]),
              ]),
              html.td([], [element.text(user_trip.start_date)]),
              html.td([], [element.text(user_trip.end_date)]),
              html.td([], [element.text(int.to_string(user_trip.places_count))]),
            ])
          }),
      ),
    ]),
  ])
}

pub fn handle_trips_dashboard_page_event(
  model: AppModel,
  event: TripsDashboardPageEvent,
) {
  case event {
    events.TripsDashboardPageUserClickedCreateTripButton -> #(
      model,
      modem.push("/trips/create", option.None, option.None),
    )
    events.TripsDashboardPageApiReturnedTrips(user_trips) -> #(
      AppModel(..model, trips_dashboard: user_trips, show_loading: False),
      effect.none(),
    )
  }
}

pub fn load_trips_dashboard() -> Effect(AppEvent) {
  let url = "http://localhost:8080/api/trips"

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(response) { trip_models.user_trips_decoder() |> decode.from(response) },
      fn(result) {
        case result {
          Ok(user_trips) ->
            events.TripsDashboardPage(events.TripsDashboardPageApiReturnedTrips(
              user_trips,
            ))
          Error(_e) -> events.OnRouteChange(routes.Login)
        }
      },
    ),
  )
}
