import frontend/api
import frontend/events.{type AppModel, type TripPlaceCreatePageEvent, AppModel}
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
import shared/trip_models

pub fn trip_place_create_view(model: AppModel, trip_id: String) {
  html.div([], [
    html.h3([], [element.text("Add a Place")]),
    html.form([], [
      html.p([], [
        html.label([], [element.text("City / Area")]),
        html.input([
          event.on_input(fn(place) {
            events.TripPlaceCreatePage(
              events.TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                events.TripPlaceCreateForm(..model.trip_place_create, place:),
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
                events.TripPlaceCreateForm(..model.trip_place_create, date:),
              ),
            )
          }),
          attribute.min(
            model.trip_details.start_date |> date_util_shared.to_yyyy_mm_dd,
          ),
          attribute.max(
            model.trip_details.end_date |> date_util_shared.to_yyyy_mm_dd,
          ),
          attribute.name("date"),
          attribute.type_("date"),
          attribute.required(True),
          attribute.value(model.trip_place_create.date),
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
          model
            |> events.set_default_trip_place_create()
            |> toast.set_success_toast("Place added"),
          effect.batch([
            effect.from(fn(dispatch) { dispatch(events.ShowToast) }),
            modem.push("/trips/" <> trip_id, option.None, option.None),
          ]),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
    events.TripPlaceCreatePageUserClickedSubmit(trip_id) -> {
      let form = model.trip_place_create
      let date = date_util_shared.from_yyyy_mm_dd(form.date)

      case date {
        Ok(date) -> #(
          model,
          api.send_create_trip_place_request(
            trip_id,
            trip_models.CreateTripPlaceRequest(place: form.place, date:),
          ),
        )
        _ -> #(model, effect.none())
      }
    }
  }
}
