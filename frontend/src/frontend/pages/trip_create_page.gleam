import frontend/api
import frontend/events.{type AppModel, type TripCreatePageEvent, AppModel}
import frontend/form_components as fc
import frontend/toast
import frontend/web
import gleam/io
import gleam/option
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/date_util_shared
import shared/id
import shared/trip_models

pub fn trip_create_view(model: AppModel) {
  html.div([], [
    html.h3([], [element.text("Create a New Trip")]),
    html.form([], [
      fc.new()
        |> fc.with_form_type(fc.SingleSelect)
        |> fc.with_countries_options(model.trip_create.destination)
        |> fc.with_label("Destination")
        |> fc.with_name("destination")
        |> fc.with_required
        |> fc.with_on_input(fn(destination) {
          events.TripCreatePage(events.TripCreatePageUserInputCreateTripRequest(
            events.CreateTripForm(..model.trip_create, destination:),
          ))
        })
        |> fc.build,
      fc.new()
        |> fc.with_form_type(fc.DateInput)
        |> fc.with_label("From")
        |> fc.with_name("from")
        |> fc.with_required
        |> fc.with_value(model.trip_create.start_date)
        |> fc.with_on_input(fn(start_date) {
          events.TripCreatePage(events.TripCreatePageUserInputCreateTripRequest(
            events.CreateTripForm(..model.trip_create, start_date:),
          ))
        })
        |> fc.build,
      fc.new()
        |> fc.with_form_type(fc.DateInput)
        |> fc.with_label("To")
        |> fc.with_name("to")
        |> fc.with_required
        |> fc.with_value(model.trip_create.end_date)
        |> fc.with_min(model.trip_create.start_date)
        |> fc.with_on_input(fn(end_date) {
          events.TripCreatePage(events.TripCreatePageUserInputCreateTripRequest(
            events.CreateTripForm(..model.trip_create, end_date:),
          ))
        })
        |> fc.build,
    ]),
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

    events.TripCreatePageUserClickedCreateTrip -> {
      let form = model.trip_create

      let start_date = date_util_shared.from_yyyy_mm_dd(form.start_date)
      let end_date = date_util_shared.from_yyyy_mm_dd(form.end_date)

      case start_date, end_date {
        Ok(start_date), Ok(end_date) -> #(
          model,
          api.send_create_trip_request(trip_models.CreateTripRequest(
            destination: form.destination,
            start_date:,
            end_date:,
          )),
        )
        _, _ -> #(model, effect.none())
      }
    }

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
