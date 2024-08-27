import frontend/events.{type AppEvent, type AppModel}
import frontend/routes
import gleam/dynamic.{type Decoder}
import gleam/json.{type Json}
import lustre/effect.{type Effect}
import lustre_http.{type HttpError}

pub fn require_ok(
  result: Result(a, HttpError),
  model: AppModel,
  next: fn(a) -> #(AppModel, Effect(AppEvent)),
) -> #(AppModel, Effect(AppEvent)) {
  case result {
    Ok(value) -> next(value)
    Error(http_error) -> {
      case http_error {
        lustre_http.Unauthorized -> #(
          events.AppModel(..model, route: routes.Login),
          effect.none(),
        )
        _ -> todo
      }
    }
  }
}

pub fn post(
  url: String,
  json: Json,
  response_decoder: Decoder(b),
  to_msg: fn(Result(b, HttpError)) -> AppEvent,
) -> Effect(AppEvent) {
  lustre_http.post(url, json, lustre_http.expect_json(response_decoder, to_msg))
}
