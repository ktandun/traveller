import decode
import frontend/events.{
  type AppEvent, type AppModel, type TripCreatePageEvent, AppModel,
}
import frontend/web
import gleam/list
import gleam/option
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import modem
import shared/id
import shared/trip_models

pub fn trip_companions_view(app_model: AppModel, trip_id: String) {
  html.div([], [
    html.h1([], [element.text("Add Companions")]),
    html.div([attribute.class("buttons")], [
      html.button(
        [
          event.on_click(events.TripCompanionsPage(
            events.TripCompanionsPageUserClickedAddMoreCompanion,
          )),
        ],
        [element.text("Add More")],
      ),
      html.button(
        [
          event.on_click(
            events.TripCompanionsPage(
              events.TripCompanionsPageUserClickedSaveCompanions(trip_id),
            ),
          ),
        ],
        [element.text("Save Companions")],
      ),
    ]),
    html.form(
      [attribute.class("companion-input")],
      list.flat_map(app_model.trip_details.user_trip_companions, fn(companion) {
        companion_input(companion)
      }),
    ),
  ])
}

pub fn handle_trip_companions_page_event(
  model: AppModel,
  event: events.TripCompanionsPageEvent,
) {
  case event {
    events.TripCompanionsPageUserClickedSaveCompanions(trip_id) -> {
      #(
        model,
        web.post(
          "http://localhost:8080/api/trips/" <> trip_id <> "/companions",
          trip_models.update_trip_companions_request(
            trip_models.update_trip_companions_request_encoder(model.trip_companions_update),
          ),
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
    events.TripCompanionsPageUserClickedAddMoreCompanion -> {
      let companions = model.trip_details.user_trip_companions
      #(
        AppModel(
          ..model,
          trip_details: trip_models.UserTripPlaces(
            ..model.trip_details,
            user_trip_companions: [
              trip_models.default_user_trip_companion(),
              ..companions
            ],
          ),
        ),
        effect.none(),
      )
    }
  }
}

fn companion_input(companion: trip_models.UserTripCompanion) {
  [
    html.p([], [
      html.label([], [element.text("Name")]),
      html.input([
        event.on_input(fn(_companion) { todo }),
        attribute.name("companion-name-" <> companion.trip_companion_id),
        attribute.type_("text"),
        attribute.required(True),
        attribute.value(companion.name),
      ]),
      html.span([attribute.class("validity")], []),
    ]),
    html.p([], [
      html.label([], [element.text("Email")]),
      html.input([
        event.on_input(fn(_companion) { todo }),
        attribute.name("companion-email-" <> companion.trip_companion_id),
        attribute.type_("email"),
        attribute.required(True),
        attribute.value(companion.email),
      ]),
      html.span([attribute.class("validity")], []),
    ]),
  ]
}
