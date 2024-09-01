import decode
import frontend/date_util
import frontend/events.{
  type AppEvent, type AppModel, type TripDetailsPageEvent, AppModel,
}
import frontend/routes
import frontend/web
import gleam/list
import gleam/option
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/trip_models

pub fn trip_details_view(app_model: AppModel) {
  html.div([], [
    html.h2([], [
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
            date_util.to_human_readable(app_model.trip_details.start_date)
            <> " to "
            <> date_util.to_human_readable(app_model.trip_details.end_date),
          ),
        ]),
      ]),
    ]),
    html.div([attribute.class("buttons")], [
      html.button(
        [
          event.on_click(
            events.TripDetailsPage(events.TripDetailsPageUserClickedUpdateTrip(
              app_model.trip_details.trip_id,
            )),
          ),
        ],
        [element.text("Edit Trip")],
      ),
      html.button(
        [
          event.on_click(
            events.TripDetailsPage(events.TripDetailsPageUserClickedCreatePlace(
              app_model.trip_details.trip_id,
            )),
          ),
        ],
        [
          element.text(case app_model.trip_details.user_trip_places {
            [] -> "Add First Place"
            _ -> "Add More Places"
          }),
        ],
      ),
      html.button(
        [
          event.on_click(
            events.TripDetailsPage(
              events.TripDetailsPageUserClickedAddCompanions(
                app_model.trip_details.trip_id,
              ),
            ),
          ),
        ],
        [element.text("Add Travel Companions")],
      ),
    ]),
    html.table([], [
      html.thead([], [
        html.tr([], [
          html.th([], [element.text("Place")]),
          html.th([], [element.text("Date")]),
          html.th([], [element.text("Maps Link")]),
        ]),
      ]),
      html.tbody(
        [],
        app_model.trip_details.user_trip_places
          |> list.map(fn(place) {
            html.tr([], [
              html.td([], [
                html.a([attribute.href("")], [element.text(place.name)]),
              ]),
              html.td([], [
                element.text(date_util.to_human_readable(place.date)),
              ]),
              html.td([], [
                case place.google_maps_link {
                  option.Some(v) ->
                    html.a([attribute.href(v), attribute.target("_blank")], [
                      element.text("Link to map"),
                    ])
                  _ -> element.text("")
                },
              ]),
            ])
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
    events.TripDetailsPageApiReturnedTripDetails(result) ->
      case result {
        Ok(user_trip_places) -> #(
          AppModel(
            ..model,
            trip_details: user_trip_places,
            trip_update: trip_models.UpdateTripRequest(
              start_date: user_trip_places.start_date,
              end_date: user_trip_places.end_date,
              destination: user_trip_places.destination,
            ),
          ),
          effect.none(),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
    events.TripDetailsPageUserClickedAddCompanions(trip_id) -> #(
      model,
      modem.push(
        "/trips/" <> trip_id <> "/add-companions",
        option.None,
        option.None,
      ),
    )
    events.TripDetailsPageUserClickedUpdateTrip(trip_id) -> #(
      model,
      modem.push("/trips/" <> trip_id <> "/update", option.None, option.None),
    )
    events.TripDetailsPageUserClickedCreatePlace(trip_id) -> #(
      model,
      modem.push(
        "/trips/" <> trip_id <> "/places/create",
        option.None,
        option.None,
      ),
    )
  }
}

pub fn load_trip_details(
  api_base_url: String,
  trip_id: String,
) -> Effect(AppEvent) {
  web.get(
    api_base_url <> "/api/trips/" <> trip_id <> "/places",
    fn(response) {
      trip_models.user_trip_places_decoder() |> decode.from(response)
    },
    fn(result) {
      events.TripDetailsPage(events.TripDetailsPageApiReturnedTripDetails(
        result,
      ))
    },
  )
}
