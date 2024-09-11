import frontend/events.{type AppModel, type TripDetailsPageEvent, AppModel}
import frontend/form_components as fc
import frontend/web
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/date_util_shared

pub fn trip_details_view(model: AppModel) {
  html.div([], [
    html.h2([], [
      element.text("Trip to "),
      html.span([attribute.class("text-cursive")], [
        element.text(model.trip_details.destination),
      ]),
    ]),
    html.div([], [
      html.dl([], [
        html.dt([], [element.text("Dates")]),
        html.dd([], [
          element.text(
            date_util_shared.to_human_readable(model.trip_details.start_date)
            <> " to "
            <> date_util_shared.to_human_readable(model.trip_details.end_date),
          ),
        ]),
        html.dt([], [element.text("Activity Fee")]),
        html.dd([], [
          element.text(
            model.trip_details.total_activities_fee |> float.to_string,
          ),
        ]),
        html.dt([], [element.text("Accomodations Fee")]),
        html.dd([], [
          element.text(
            model.trip_details.total_accomodations_fee |> float.to_string,
          ),
        ]),
      ]),
    ]),
    html.div([attribute.class("buttons")], [
      html.button(
        [
          event.on_click(
            events.TripDetailsPage(events.TripDetailsPageUserClickedUpdateTrip(
              model.trip_details.trip_id,
            )),
          ),
        ],
        [element.text("Edit Trip")],
      ),
      html.button(
        [
          event.on_click(
            events.TripDetailsPage(events.TripDetailsPageUserClickedCreatePlace(
              model.trip_details.trip_id,
            )),
          ),
        ],
        [
          element.text(case model.trip_details.user_trip_places {
            [] -> "Add First City"
            _ -> "Add More Cities"
          }),
        ],
      ),
      html.button(
        [
          event.on_click(
            events.TripDetailsPage(
              events.TripDetailsPageUserClickedAddCompanions(
                model.trip_details.trip_id,
              ),
            ),
          ),
        ],
        [element.text("Add Travel Companions")],
      ),
    ]),
    html.figure([], [
      html.table([], [
        html.thead([], [
          html.tr([], [
            html.th([], [element.text("City / Area")]),
            html.th([], [element.text("Date")]),
            html.th([], [element.text("Accomodation")]),
            html.th([], [element.text("Activities")]),
          ]),
        ]),
        html.tbody(
          [],
          model.trip_details.user_trip_places
            |> list.map(fn(place) {
              html.tr([], [
                html.td([], [element.text(place.name)]),
                html.td([], [
                  element.text(date_util_shared.to_human_readable(place.date)),
                ]),
                html.td([], [
                  html.a(
                    [
                      attribute.href(
                        "/trips/"
                        <> model.trip_details.trip_id
                        <> "/places/"
                        <> place.trip_place_id
                        <> "/accomodations/",
                      ),
                    ],
                    [
                      element.text(case
                        place.has_accomodation,
                        place.accomodation_paid
                      {
                        True, True -> "Paid"
                        True, False -> "Booked, not paid"
                        _, _ -> "Not booked"
                      }),
                    ],
                  ),
                ]),
                html.td([], [
                  html.a(
                    [
                      attribute.href(
                        "/trips/"
                        <> model.trip_details.trip_id
                        <> "/places/"
                        <> place.trip_place_id
                        <> "/activities/",
                      ),
                    ],
                    [
                      element.text(case place.activities_count {
                        0 -> "None planned"
                        count -> int.to_string(count) <> " planned"
                      }),
                    ],
                  ),
                ]),
              ])
            }),
        ),
      ]),
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
            trip_update: events.TripUpdateForm(
              start_date: user_trip_places.start_date
                |> date_util_shared.to_yyyy_mm_dd,
              end_date: user_trip_places.end_date
                |> date_util_shared.to_yyyy_mm_dd,
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
