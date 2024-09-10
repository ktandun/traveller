import frontend/api
import frontend/events.{
  type AppModel, type TripPlaceAccomodationPageEvent, AppModel,
}
import frontend/form_components as fc
import frontend/uuid_util
import frontend/web
import gleam/float
import gleam/option
import gleam/string
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import shared/trip_models

pub fn trip_place_accomodations_view(
  model: AppModel,
  trip_id: String,
  trip_place_id: String,
) {
  let accomodation = model.trip_place_accomodation

  html.div([], [
    html.h3([], [
      element.text("Accomodation in "),
      html.span([attribute.class("text-cursive")], [
        element.text(accomodation.place_name),
      ]),
    ]),
    html.div([], [
      fc.new()
        |> fc.with_label("Accomodation Name")
        |> fc.with_name("accomodation-name")
        |> fc.with_required
        |> fc.with_placeholder("XY Hotel")
        |> fc.with_value(accomodation.accomodation_name)
        |> fc.with_on_input(fn(accomodation_name) {
          events.TripPlaceAccomodationPage(
            events.TripPlaceAccomodationPageUserInputForm(
              events.PlaceAccomodationForm(..accomodation, accomodation_name:),
            ),
          )
        })
        |> fc.build,
      fc.new()
        |> fc.with_label("Information URL")
        |> fc.with_name("information-url")
        |> fc.with_placeholder("https://...")
        |> fc.with_value(accomodation.information_url)
        |> fc.with_on_input(fn(information_url) {
          events.TripPlaceAccomodationPage(
            events.TripPlaceAccomodationPageUserInputForm(
              events.PlaceAccomodationForm(..accomodation, information_url:),
            ),
          )
        })
        |> fc.build,
      fc.new()
        |> fc.with_form_type(fc.MoneyInput)
        |> fc.with_label("Accomodation Fee")
        |> fc.with_name("accomodation-fee")
        |> fc.with_required
        |> fc.with_value(accomodation.accomodation_fee)
        |> fc.with_on_input(fn(accomodation_fee) {
          events.TripPlaceAccomodationPage(
            events.TripPlaceAccomodationPageUserInputForm(
              events.PlaceAccomodationForm(..accomodation, accomodation_fee:),
            ),
          )
        })
        |> fc.build,
      fc.new()
        |> fc.with_form_type(fc.Checkbox)
        |> fc.with_label("Paid")
        |> fc.with_name("paid")
        |> fc.with_checked(accomodation.paid)
        |> fc.with_on_check(fn(paid) {
          events.TripPlaceAccomodationPage(
            events.TripPlaceAccomodationPageUserInputForm(
              events.PlaceAccomodationForm(..accomodation, paid:),
            ),
          )
        })
        |> fc.build,
    ]),
    html.div([attribute.class("buttons")], [
      html.button(
        [
          event.on_click(
            events.TripPlaceAccomodationPage(
              events.TripPlaceAccomodationPageUserClickedSave(
                trip_id,
                trip_place_id,
              ),
            ),
          ),
        ],
        [element.text("Save Accomodation")],
      ),
    ]),
  ])
}

pub fn handle_trip_place_accomodations_page_event(
  model: AppModel,
  event: TripPlaceAccomodationPageEvent,
) {
  case event {
    events.TripPlaceAccomodationPageUserInputForm(form) -> #(
      model |> events.set_trip_place_accomodation(form),
      effect.none(),
    )
    events.TripPlaceAccomodationPageUserClickedSave(trip_id, trip_place_id) -> #(
      model,
      api.send_place_accomodation_update_request(
        trip_id,
        trip_place_id,
        trip_models.PlaceAccomodation(
          place_accomodation_id: model.trip_place_accomodation.place_accomodation_id,
          place_name: model.trip_place_accomodation.place_name,
          accomodation_name: model.trip_place_accomodation.accomodation_name,
          information_url: case
            string.is_empty(model.trip_place_accomodation.information_url)
          {
            True -> option.None
            False -> option.Some(model.trip_place_accomodation.information_url)
          },
          accomodation_fee: case
            float.parse(model.trip_place_accomodation.accomodation_fee)
          {
            Ok(accomodation_fee) -> option.Some(accomodation_fee)
            Error(_) -> option.None
          },
          paid: model.trip_place_accomodation.paid,
        ),
      ),
    )
    events.TripPlaceAccomodationPageApiReturnedSaveResponse(response) -> #(
      model,
      effect.none(),
    )
    events.TripPlaceAccomodationPageApiReturnedAccomodation(response) ->
      case response {
        Ok(response) -> #(
          model
            |> events.set_trip_place_accomodation(events.PlaceAccomodationForm(
              place_accomodation_id: case
                string.is_empty(response.place_accomodation_id)
              {
                True -> uuid_util.gen_uuid()
                False -> response.place_accomodation_id
              },
              place_name: response.place_name,
              accomodation_name: response.accomodation_name,
              information_url: option.unwrap(response.information_url, ""),
              accomodation_fee: option.unwrap(response.accomodation_fee, 0.0)
                |> float.to_string,
              paid: response.paid,
            )),
          effect.none(),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
  }
}
