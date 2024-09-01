import decode
import frontend/events.{type AppModel, type TripCreatePageEvent, AppModel}
import frontend/toast
import frontend/web
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import modem
import shared/id
import shared/trip_models

pub fn trip_create_view(app_model: AppModel) {
  html.div([], [
    html.h3([], [element.text("Create a New Trip")]),
    html.form([], [
      html.p([], [
        html.label([], [element.text("From")]),
        html.input([
          event.on_input(fn(start_date) {
            events.TripCreatePage(
              events.TripCreatePageUserInputCreateTripRequest(
                trip_models.CreateTripRequest(
                  ..app_model.trip_create,
                  start_date:,
                ),
              ),
            )
          }),
          attribute.name("from"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(app_model.trip_create.start_date),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("To")]),
        html.input([
          event.on_input(fn(end_date) {
            events.TripCreatePage(
              events.TripCreatePageUserInputCreateTripRequest(
                trip_models.CreateTripRequest(
                  ..app_model.trip_create,
                  end_date:,
                ),
              ),
            )
          }),
          attribute.min(app_model.trip_create.start_date),
          attribute.name("to"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(app_model.trip_create.end_date),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("Destination")]),
        html.input([
          event.on_input(fn(destination) {
            events.TripCreatePage(
              events.TripCreatePageUserInputCreateTripRequest(
                trip_models.CreateTripRequest(
                  ..app_model.trip_create,
                  destination:,
                ),
              ),
            )
          }),
          attribute.name("destination"),
          attribute.placeholder("Where are you going?"),
          attribute.type_("text"),
          attribute.required(True),
          attribute.value(app_model.trip_create.destination),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
    ]),
    html.div([], [element.text(app_model.trip_create_errors)]),
    html.button(
      [
        event.on_click(events.TripCreatePage(
          events.TripCreatePageUserClickedCreateTrip,
        )),
      ],
      [element.text("Create Trip")],
    ),
  ])
}

pub fn handle_trip_create_page_event(
  model: AppModel,
  event: TripCreatePageEvent,
) {
  case event {
    events.TripCreatePageUserInputCreateTripRequest(create_trip_request) -> #(
      AppModel(..model, trip_create: create_trip_request),
      effect.none(),
    )
    events.TripCreatePageUserClickedCreateTrip -> #(
      model,
      web.post(
        model.api_base_url <> "/api/trips",
        trip_models.create_trip_request_encoder(model.trip_create),
        fn(response) { id.id_decoder() |> decode.from(response) },
        fn(result) {
          events.TripCreatePage(events.TripCreatePageApiReturnedResponse(result))
        },
      ),
    )
    events.TripCreatePageApiReturnedResponse(response) -> {
      case response {
        Ok(trip_id) -> {
          let trip_id = id.id_value(trip_id)

          #(
            model
              |> events.set_default_trip_create()
              |> toast.set_success_toast(content: "Trip Created"),
            effect.batch([
              effect.from(fn(dispatch) { dispatch(events.ShowToast) }),
              modem.push("/trips/" <> trip_id, option.None, option.None),
            ]),
          )
        }
        Error(e) -> web.error_to_app_event(e, model)
      }
    }
  }
}
