import frontend/events.{type AppEvent, type AppModel}
import frontend/routes
import gleam/dynamic.{type Decoder}
import gleam/http
import gleam/http/request
import gleam/json.{type Json}
import gleam/result
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
        _ -> #(model, effect.none())
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

pub fn put(
  url: String,
  json: Json,
  response_decoder: Decoder(b),
  to_msg: fn(Result(b, HttpError)) -> AppEvent,
) -> Effect(AppEvent) {
  let req =
    request.to(url)
    |> result.unwrap(request.new())
    |> request.set_header("Content-Type", "application/json")
    |> request.set_body(json.to_string(json))

  req
  |> request.set_method(http.Put)
  |> lustre_http.send(lustre_http.expect_json(response_decoder, to_msg))
}

pub fn get(
  url: String,
  response_decoder: Decoder(b),
  to_msg: fn(Result(b, HttpError)) -> AppEvent,
) -> Effect(AppEvent) {
  lustre_http.get(url, lustre_http.expect_json(response_decoder, to_msg))
}

pub fn delete(
  url: String,
  to_msg: fn(Result(Nil, HttpError)) -> AppEvent,
) -> Effect(AppEvent) {
  let req =
    request.to(url)
    |> result.unwrap(request.new())

  req
  |> request.set_method(http.Delete)
  |> lustre_http.send(
    lustre_http.expect_anything(fn(response) { to_msg(response) }),
  )
}
