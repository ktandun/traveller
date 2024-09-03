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
  todo
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
      api.send_create_trip_place_request(trip_id, todo),
    )
  }
}
