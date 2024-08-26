import decode
import frontend/events.{
  type AppEvent, type AppModel, type TripCreatePageEvent, AppModel,
}
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

pub fn trip_create_view(app_model: AppModel) {
  html.div([], [
    html.h1([], [element.text("Create a New Trip")]),
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
      handle_create_trip(model.trip_create),
    )
    events.TripCreatePageApiReturnedResponse(response) -> {
      case response {
        Ok(_) -> #(
          AppModel(
            ..model,
            trip_create: trip_models.default_create_trip_request(),
            trip_create_errors: "",
          ),
          modem.push("/dashboard", option.None, option.None),
        )
        Error(e) -> {
          case e {
            lustre_http.OtherError(400, error) -> #(
              AppModel(..model, trip_create_errors: error),
              effect.none(),
            )

            lustre_http.OtherError(401, _) -> #(
              model,
              modem.push("/login", option.None, option.None),
            )
            _ -> #(model, effect.none())
          }
        }
      }
    }
  }
}

fn handle_create_trip(
  create_trip_request: trip_models.CreateTripRequest,
) -> Effect(AppEvent) {
  let url = "http://localhost:8080/api/trips"

  let json = trip_models.create_trip_request_encoder(create_trip_request)

  lustre_http.post(
    url,
    json,
    lustre_http.expect_json(
      fn(response) { id.id_decoder() |> decode.from(response) },
      fn(result) {
        events.TripCreatePage(events.TripCreatePageApiReturnedResponse(result))
      },
    ),
  )
}
