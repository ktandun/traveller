import decode
import frontend/events.{type AppModel, type TripPlaceCreatePageEvent, AppModel}
import frontend/web
import gleam/io
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/id
import shared/trip_models

pub fn trip_place_create_view(app_model: AppModel, trip_id: String) {
  html.div([], [
    html.h1([], [element.text("Add a Place")]),
    html.form([], [
      html.p([], [
        html.label([], [element.text("Place")]),
        html.input([
          event.on_input(fn(place) {
            events.TripPlaceCreatePage(
              events.TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                trip_models.CreateTripPlaceRequest(
                  ..app_model.trip_place_create,
                  place:,
                ),
              ),
            )
          }),
          attribute.name("place"),
          attribute.required(True),
          attribute.placeholder("Name of place"),
          attribute.value(app_model.trip_place_create.place),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("Date")]),
        html.input([
          event.on_input(fn(date) {
            events.TripPlaceCreatePage(
              events.TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                trip_models.CreateTripPlaceRequest(
                  ..app_model.trip_place_create,
                  date:,
                ),
              ),
            )
          }),
          attribute.min(app_model.trip_details.start_date),
          attribute.max(app_model.trip_details.end_date),
          attribute.name("date"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(app_model.trip_place_create.date),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("Google Maps Link")]),
        html.input([
          event.on_input(fn(google_maps_link) {
            events.TripPlaceCreatePage(
              events.TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                trip_models.CreateTripPlaceRequest(
                  ..app_model.trip_place_create,
                  google_maps_link: option.Some(google_maps_link),
                ),
              ),
            )
          }),
          attribute.name("google_maps_link"),
          attribute.placeholder("https://..."),
          attribute.type_("text"),
          attribute.required(True),
          attribute.value(case app_model.trip_place_create.google_maps_link {
            option.Some(val) -> val
            _ -> ""
          }),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
    ]),
    html.div([], [element.text(app_model.trip_create_errors)]),
    html.button(
      [
        event.on_click(
          events.TripPlaceCreatePage(
            events.TripPlaceCreatePageUserClickedSubmit(trip_id),
          ),
        ),
      ],
      [element.text("Add Place")],
    ),
  ])
}

pub fn handle_trip_place_create_page_event(
  model: AppModel,
  event: TripPlaceCreatePageEvent,
) {
  case event {
    events.TripPlaceCreatePageUserInputCreateTripPlaceRequest(
      create_trip_place_request,
    ) -> #(
      AppModel(..model, trip_place_create: create_trip_place_request),
      effect.none(),
    )
    events.TripPlaceCreatePageApiReturnedResponse(trip_id, response) ->
      case response {
        Ok(_) -> #(
          AppModel(
            ..model,
            trip_place_create: trip_models.default_create_trip_place_request(),
          ),
          modem.push("/trips/" <> trip_id, option.None, option.None),
        )
        Error(_) -> #(model, effect.none())
      }
    events.TripPlaceCreatePageUserClickedSubmit(trip_id) -> #(
      model,
      web.post(
        "http://localhost:8080/api/trips/" <> trip_id <> "/places",
        trip_models.create_trip_place_request_encoder(model.trip_place_create),
        fn(response) { id.id_decoder() |> decode.from(response) },
        fn(decode_result) {
          events.TripPlaceCreatePage(
            events.TripPlaceCreatePageApiReturnedResponse(
              trip_id,
              decode_result,
            ),
          )
        },
      ),
    )
  }
}
