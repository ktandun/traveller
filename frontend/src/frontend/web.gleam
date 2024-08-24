import frontend/events.{type AppEvent, type AppModel}
import frontend/routes
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
