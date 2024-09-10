import frontend/api
import frontend/events.{type AppModel, type TripUpdatePageEvent, AppModel}
import frontend/form_components as fc
import frontend/toast
import frontend/web
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/date_util_shared
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
      fc.new()
        |> fc.with_form_type(fc.SingleSelect)
        |> fc.with_countries_options(model.trip_update.destination)
        |> fc.with_label("Destination")
        |> fc.with_name("destination")
        |> fc.with_required
        |> fc.with_on_input(fn(destination) {
          events.TripUpdatePage(events.TripUpdatePageUserInputUpdateTripRequest(
            events.TripUpdateForm(..model.trip_update, destination:),
          ))
        })
        |> fc.build,
      fc.new()
        |> fc.with_form_type(fc.DateInput)
        |> fc.with_label("From")
        |> fc.with_name("from")
        |> fc.with_required
        |> fc.with_value(model.trip_update.start_date)
        |> fc.with_on_input(fn(start_date) {
          events.TripUpdatePage(events.TripUpdatePageUserInputUpdateTripRequest(
            events.TripUpdateForm(..model.trip_update, start_date:),
          ))
        })
        |> fc.build,
      fc.new()
        |> fc.with_form_type(fc.DateInput)
        |> fc.with_label("To")
        |> fc.with_name("to")
        |> fc.with_required
        |> fc.with_value(model.trip_update.end_date)
        |> fc.with_min(model.trip_update.start_date)
        |> fc.with_on_input(fn(end_date) {
          events.TripUpdatePage(events.TripUpdatePageUserInputUpdateTripRequest(
            events.TripUpdateForm(..model.trip_update, end_date:),
          ))
        })
        |> fc.build,
    ]),
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
    events.TripUpdatePageUserClickedUpdateTrip(trip_id) -> {
      let form = model.trip_update

      let start_date = date_util_shared.from_yyyy_mm_dd(form.start_date)
      let end_date = date_util_shared.from_yyyy_mm_dd(form.end_date)

      case start_date, end_date {
        Ok(start_date), Ok(end_date) -> #(
          model,
          api.send_trip_update_request(
            trip_id,
            trip_models.UpdateTripRequest(
              destination: form.destination,
              start_date:,
              end_date:,
            ),
          ),
        )
        _, _ -> #(model, effect.none())
      }
    }
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
