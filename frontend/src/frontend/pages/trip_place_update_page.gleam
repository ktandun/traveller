import frontend/api
import frontend/events.{type AppModel, type TripPlaceUpdatePageEvent, AppModel}
import frontend/toast
import frontend/web
import gleam/list
import gleam/option
import gleam/result
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/date_util_shared
import shared/trip_models

pub fn trip_place_update_view(
  model: AppModel,
  trip_id: String,
  trip_place_id: String,
) {
  html.div([], [
    html.h3([], [element.text("Update Place")]),
    html.form([], [
      html.p([], [
        html.label([], [element.text("City / Area")]),
        html.input([
          event.on_input(fn(place) {
            events.TripPlaceUpdatePage(
              events.TripPlaceUpdatePageUserInputUpdateTripPlaceRequest(
                events.TripPlaceUpdateForm(..model.trip_place_update, place:),
              ),
            )
          }),
          attribute.name("place"),
          attribute.required(True),
          attribute.placeholder("Name of place"),
          attribute.value(model.trip_place_update.place),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
      html.p([], [
        html.label([], [element.text("Date")]),
        html.input([
          event.on_input(fn(date) {
            events.TripPlaceUpdatePage(
              events.TripPlaceUpdatePageUserInputUpdateTripPlaceRequest(
                events.TripPlaceUpdateForm(..model.trip_place_update, date:),
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
          attribute.value(model.trip_place_update.date),
        ]),
        html.span([attribute.class("validity")], []),
      ]),
    ]),
    html.div([], [element.text(model.trip_update_errors)]),
    html.button(
      [
        event.on_click(
          events.TripPlaceUpdatePage(
            events.TripPlaceUpdatePageUserClickedSubmit(trip_id, trip_place_id),
          ),
        ),
      ],
      [element.text("Update")],
    ),
  ])
}

pub fn handle_trip_place_update_page_event(
  model: AppModel,
  event: TripPlaceUpdatePageEvent,
) {
  case event {
    events.TripPlaceUpdatePageOnLoad -> #(
      model |> events.set_trip_place_update_form_from_place_details(),
      effect.none(),
    )
    events.TripPlaceUpdatePageUserInputUpdateTripPlaceRequest(
      update_trip_place_request,
    ) -> #(
      AppModel(..model, trip_place_update: update_trip_place_request),
      effect.none(),
    )
    events.TripPlaceUpdatePageApiReturnedResponse(trip_id, response) ->
      case response {
        Ok(_) -> #(
          model
            |> events.set_default_trip_place_update()
            |> toast.set_success_toast("Place updated"),
          effect.batch([
            effect.from(fn(dispatch) { dispatch(events.ShowToast) }),
            modem.push("/trips/" <> trip_id, option.None, option.None),
          ]),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
    events.TripPlaceUpdatePageUserClickedSubmit(trip_id, trip_place_id) -> {
      let form = model.trip_place_update
      let date = date_util_shared.from_yyyy_mm_dd(form.date)

      case date {
        Ok(date) -> #(
          model,
          api.send_upsert_trip_place_request(
            trip_id,
            option.Some(trip_place_id),
            trip_models.CreateTripPlaceRequest(place: form.place, date:),
          ),
        )
        _ -> #(model, effect.none())
      }
    }
  }
}
