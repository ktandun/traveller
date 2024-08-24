import decode
import frontend/events.{
  type AppEvent, type AppModel, type TripDetailsPageEvent, AppModel,
}
import frontend/routes
import gleam/list
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre_http
import shared/trip_models

pub fn trip_details_view(app_model: AppModel) {
  html.div([], [
    html.h1([], [
      element.text("Trip to "),
      html.span([attribute.class("text-cursive")], [
        element.text(app_model.trip_details.destination),
      ]),
    ]),
    html.div([], [
      html.dl([], [
        html.dt([], [element.text("Dates")]),
        html.dd([], [
          element.text(
            app_model.trip_details.start_date
            <> " to "
            <> app_model.trip_details.end_date,
          ),
        ]),
      ]),
    ]),
    html.table([], [
      html.thead([], [html.tr([], [
        html.th([], [element.text("Place")]),
        html.th([], [element.text("Date")]),
        html.th([], [element.text("Maps Link")])
      ])]),
      html.tbody(
        [],
        app_model.trip_details.user_trip_places
          |> list.map(fn(place) {
            html.tr([], [html.td([], [element.text(place.name)])])
          }),
      ),
    ]),
  ])
}

pub fn handle_trip_details_page_event(
  model: AppModel,
  event: TripDetailsPageEvent,
) {
  case event {
    events.TripDetailsPageApiReturnedTripDetails(user_trip_places) -> #(
      AppModel(..model, trip_details: user_trip_places),
      effect.none(),
    )
  }
}

pub fn load_trip_details(trip_id: String) -> Effect(AppEvent) {
  let url = "http://localhost:8080/api/trips/" <> trip_id <> "/places"

  lustre_http.get(
    url,
    lustre_http.expect_json(
      fn(response) {
        trip_models.user_trip_places_decoder() |> decode.from(response)
      },
      fn(result) {
        case result {
          Ok(user_trip_places) ->
            events.TripDetailsPage(events.TripDetailsPageApiReturnedTripDetails(
              user_trip_places,
            ))
          Error(_e) -> events.OnRouteChange(routes.Login)
        }
      },
    ),
  )
}
