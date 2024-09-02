import frontend/api
import frontend/events.{type AppModel, type TripUpdatePageEvent, AppModel}
import frontend/toast
import frontend/web
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/id
import shared/trip_models

pub fn trip_update_view(model: AppModel, trip_id: String) {
  html.div([], [
    html.h3([], [
      element.text("Update Trip to "),
      html.span([attribute.class("text-cursive")], [
        element.text(model.trip_details.destination),
      ]),
    ]),
    html.form([], [
      html.p([], [
        html.label([], [element.text("From")]),
        html.input([
          event.on_input(fn(start_date) {
            events.TripUpdatePage(
              events.TripUpdatePageUserInputUpdateTripRequest(
                trip_models.UpdateTripRequest(..model.trip_update, start_date:),
              ),
            )
          }),
          attribute.name("from"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(model.trip_update.start_date),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("To")]),
        html.input([
          event.on_input(fn(end_date) {
            events.TripUpdatePage(
              events.TripUpdatePageUserInputUpdateTripRequest(
                trip_models.UpdateTripRequest(..model.trip_update, end_date:),
              ),
            )
          }),
          attribute.min(model.trip_update.start_date),
          attribute.name("to"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(model.trip_update.end_date),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("Destination")]),
        html.input([
          event.on_input(fn(destination) {
            events.TripUpdatePage(
              events.TripUpdatePageUserInputUpdateTripRequest(
                trip_models.UpdateTripRequest(..model.trip_update, destination:),
              ),
            )
          }),
          attribute.name("destination"),
          attribute.placeholder("Where are you going?"),
          attribute.type_("text"),
          attribute.required(True),
          attribute.value(model.trip_update.destination),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
    ]),
    html.div([], [element.text(model.trip_update_errors)]),
    html.button(
      [
        event.on_click(
          events.TripUpdatePage(events.TripUpdatePageUserClickedUpdateTrip(
            trip_id,
          )),
        ),
      ],
      [element.text("Update Trip")],
    ),
  ])
}

pub fn handle_trip_update_page_event(
  model: AppModel,
  event: TripUpdatePageEvent,
) {
  case event {
    events.TripUpdatePageUserInputUpdateTripRequest(update_trip_request) -> #(
      AppModel(..model, trip_update: update_trip_request),
      effect.none(),
    )
    events.TripUpdatePageUserClickedUpdateTrip(trip_id) -> #(
      model,
      api.send_trip_update_request(trip_id, model.trip_update),
    )
    events.TripUpdatePageApiReturnedResponse(response) -> {
      case response {
        Ok(trip_id) -> {
          let trip_id = id.id_value(trip_id)
          #(
            model
              |> events.set_default_trip_update()
              |> toast.set_success_toast("Trip updated"),
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
