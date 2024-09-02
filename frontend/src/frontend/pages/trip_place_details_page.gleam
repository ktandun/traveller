import frontend/api
import frontend/events.{type AppModel, type TripPlaceCreatePageEvent, AppModel}
import frontend/toast
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/trip_models

pub fn trip_place_details_view(
  model: AppModel,
  trip_id: String,
  trip_place_id: String,
) {
  html.div([], [
    html.h3([], [element.text("Add a Place")]),
    html.form([], [
      html.p([], [
        html.label([], [element.text("Place")]),
        html.input([
          event.on_input(fn(place) {
            events.TripPlaceCreatePage(
              events.TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                trip_models.CreateTripPlaceRequest(
                  ..model.trip_place_create,
                  place:,
                ),
              ),
            )
          }),
          attribute.name("place"),
          attribute.required(True),
          attribute.placeholder("Name of place"),
          attribute.value(model.trip_place_create.place),
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
                  ..model.trip_place_create,
                  date:,
                ),
              ),
            )
          }),
          attribute.min(model.trip_details.start_date),
          attribute.max(model.trip_details.end_date),
          attribute.name("date"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(model.trip_place_create.date),
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
                  ..model.trip_place_create,
                  google_maps_link: option.Some(google_maps_link),
                ),
              ),
            )
          }),
          attribute.name("google_maps_link"),
          attribute.placeholder("https://..."),
          attribute.type_("text"),
          attribute.required(True),
          attribute.value(case model.trip_place_create.google_maps_link {
            option.Some(val) -> val
            _ -> ""
          }),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
    ]),
    html.div([], [element.text(model.trip_create_errors)]),
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

pub fn handle_trip_place_details_page_event(
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
          model
            |> events.set_default_trip_place_create()
            |> toast.set_success_toast("Place added"),
          effect.batch([
            effect.from(fn(dispatch) { dispatch(events.ShowToast) }),
            modem.push("/trips/" <> trip_id, option.None, option.None),
          ]),
        )
        Error(_) -> #(model, effect.none())
      }
    events.TripPlaceCreatePageUserClickedSubmit(trip_id) -> #(
      model,
      api.send_create_trip_place_request(trip_id, model.trip_place_create),
    )
  }
}
