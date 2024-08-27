import decode
import frontend/date_util
import frontend/events.{
  type AppEvent, type AppModel, type TripDetailsPageEvent, AppModel,
}
import frontend/routes
import gleam/http
import gleam/http/request
import gleam/list
import gleam/option
import gleam/result
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import modem
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
            date_util.to_human_readable(app_model.trip_details.start_date)
            <> " to "
            <> date_util.to_human_readable(app_model.trip_details.end_date),
          ),
        ]),
      ]),
    ]),
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
    html.table([], [
      html.thead([], [
        html.tr([], [
          html.th([], [element.text("Place")]),
          html.th([], [element.text("Date")]),
          html.th([], [element.text("Maps Link")]),
          html.th([], [element.text("Actions")]),
        ]),
      ]),
      html.tbody(
        [],
        app_model.trip_details.user_trip_places
          |> list.map(fn(place) {
            html.tr([], [
              html.td([], [element.text(place.name)]),
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
              html.td([], [
                html.button(
                  [
                    event.on_click(
                      events.TripDetailsPage(
                        events.TripDetailsPageUserClickedRemovePlace(
                          place.trip_place_id,
                        ),
                      ),
                    ),
                  ],
                  [element.text("Remove")],
                ),
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
    events.TripDetailsPageApiReturnedTripDetails(user_trip_places) -> #(
      AppModel(..model, trip_details: user_trip_places),
      effect.none(),
    )
    events.TripDetailsPageUserClickedRemovePlace(trip_place_id) -> #(
      model,
      delete_trip_place(model.trip_details.trip_id, trip_place_id),
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

pub fn delete_trip_place(
  trip_id: String,
  trip_place_id: String,
) -> Effect(AppEvent) {
  let url =
    "http://localhost:8080/api/trips/" <> trip_id <> "/places/" <> trip_place_id

  let req =
    url
    |> request.to()
    |> result.unwrap(request.new())

  req
  |> request.set_method(http.Delete)
  |> lustre_http.send(
    lustre_http.expect_anything(fn(result) {
      case result {
        Ok(_) -> events.OnRouteChange(routes.TripDetails(trip_id))
        Error(_e) -> events.OnRouteChange(routes.Login)
      }
    }),
  )
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
