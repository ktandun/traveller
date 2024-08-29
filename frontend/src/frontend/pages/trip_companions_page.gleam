import frontend/events.{type AppModel, AppModel}
import frontend/uuid_util
import frontend/web
import gleam/dynamic
import gleam/list
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import modem
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
        [
          element.text(case
            list.is_empty(app_model.trip_details.user_trip_companions)
          {
            True -> "Add First Companion"
            False -> "Add More"
          }),
        ],
      ),
      html.button(
        [
          event.on_click(
            events.TripCompanionsPage(
              events.TripCompanionsPageUserClickedSaveCompanions(trip_id),
            ),
          ),
        ],
        [element.text("Save")],
      ),
    ]),
    html.form([attribute.class("companion-input")], [
      html.table([], [
        html.thead([], [
          html.tr([], [
            html.th([], [element.text("Name")]),
            html.th([], [element.text("Email")]),
            html.th([], [element.text("")]),
          ]),
        ]),
        html.tbody(
          [],
          list.map(app_model.trip_details.user_trip_companions, fn(companion) {
            companion_input(companion)
          }),
        ),
      ]),
    ]),
  ])
}

pub fn handle_trip_companions_page_event(
  model: AppModel,
  event: events.TripCompanionsPageEvent,
) {
  case event {
    events.TripCompanionsPageUserClickedSaveCompanions(trip_id) -> {
      let update_trip_companions_request =
        trip_models.UpdateTripCompanionsRequest(
          trip_companions: model.trip_details.user_trip_companions
          |> list.map(fn(companion) {
            trip_models.TripCompanion(
              trip_companion_id: companion.trip_companion_id,
              name: companion.name,
              email: companion.email,
            )
          }),
        )

      #(
        AppModel(..model, show_loading: True),
        web.post(
          "http://localhost:8080/api/trips/" <> trip_id <> "/companions",
          trip_models.update_trip_companions_request_encoder(
            update_trip_companions_request,
          ),
          fn(response) { dynamic.dynamic(response) },
          fn(decode_result) {
            events.TripCompanionsPage(
              events.TripCompanionsPageApiReturnedResponse(
                trip_id,
                decode_result,
              ),
            )
          },
        ),
      )
    }
    events.TripCompanionsPageApiReturnedResponse(trip_id, response) -> {
      let model = AppModel(..model, show_loading: False)
      case response {
        Ok(_) -> #(
          model,
          modem.push("/trips/" <> trip_id, option.None, option.None),
        )
        Error(e) -> {
          case e {
            lustre_http.OtherError(400, _) -> #(model, effect.none())
            lustre_http.OtherError(401, _) -> #(
              model,
              modem.push("/login", option.None, option.None),
            )
            _ -> #(model, effect.none())
          }
        }
      }
    }
    events.TripCompanionsPageUserUpdatedCompanion(companion) -> {
      #(
        AppModel(
          ..model,
          trip_details: trip_models.UserTripPlaces(
            ..model.trip_details,
            user_trip_companions: model.trip_details.user_trip_companions
              |> list.map(fn(trip_companion) {
                case
                  trip_companion.trip_companion_id
                  == companion.trip_companion_id
                {
                  True -> companion
                  False -> trip_companion
                }
              }),
          ),
        ),
        effect.none(),
      )
    }
    events.TripCompanionsPageUserClickedRemoveCompanion(trip_companion_id) -> {
      #(
        AppModel(
          ..model,
          trip_details: trip_models.UserTripPlaces(
            ..model.trip_details,
            user_trip_companions: model.trip_details.user_trip_companions
              |> list.filter(fn(companion) {
                companion.trip_companion_id != trip_companion_id
              }),
          ),
        ),
        effect.none(),
      )
    }
    events.TripCompanionsPageUserClickedAddMoreCompanion -> {
      let companions = model.trip_details.user_trip_companions
      let new_companion =
        trip_models.UserTripCompanion(
          ..trip_models.default_user_trip_companion(),
          trip_companion_id: uuid_util.gen_uuid(),
        )

      #(
        AppModel(
          ..model,
          trip_details: trip_models.UserTripPlaces(
            ..model.trip_details,
            user_trip_companions: [new_companion, ..companions],
          ),
        ),
        effect.none(),
      )
    }
  }
}

fn companion_input(companion: trip_models.UserTripCompanion) {
  html.tr([], [
    html.td([], [
      html.input([
        event.on_input(fn(name) {
          events.TripCompanionsPage(
            events.TripCompanionsPageUserUpdatedCompanion(
              trip_models.UserTripCompanion(..companion, name:),
            ),
          )
        }),
        attribute.name("companion-name-" <> companion.trip_companion_id),
        attribute.type_("text"),
        attribute.required(True),
        attribute.value(companion.name),
      ]),
      html.span([attribute.class("validity")], []),
    ]),
    html.td([], [
      html.input([
        event.on_input(fn(email) {
          events.TripCompanionsPage(
            events.TripCompanionsPageUserUpdatedCompanion(
              trip_models.UserTripCompanion(..companion, email:),
            ),
          )
        }),
        attribute.name("companion-email-" <> companion.trip_companion_id),
        attribute.type_("email"),
        attribute.required(True),
        attribute.value(companion.email),
      ]),
      html.span([attribute.class("validity")], []),
    ]),
    html.td([], [
      html.button(
        [
          attribute.type_("button"),
          event.on_click(
            events.TripCompanionsPage(
              events.TripCompanionsPageUserClickedRemoveCompanion(
                companion.trip_companion_id,
              ),
            ),
          ),
        ],
        [element.text("Remove")],
      ),
    ]),
  ])
}
