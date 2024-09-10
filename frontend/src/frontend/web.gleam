import frontend/events.{type AppEvent, type AppModel}
import frontend/loading_spinner
import frontend/routes
import frontend/toast
import gleam/io
import gleam/option
import lustre/effect.{type Effect}
import lustre_http.{type HttpError}
import modem

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

pub fn error_to_app_event(error: HttpError, model: AppModel) {
  let model = model |> events.set_hide_loading()

  case error {
    lustre_http.OtherError(400, _content) -> #(
      model
        |> toast.set_form_validation_failed_toast
        |> loading_spinner.hide_loading_spinner,
      effect.batch([effect.from(fn(dispatch) { dispatch(events.ShowToast) })]),
    )
    lustre_http.Unauthorized -> #(
      model,
      modem.push("/login", option.None, option.None),
    )
    lustre_http.OtherError(403, _content) -> #(
      model,
      modem.push("/403", option.None, option.None),
    )
    lustre_http.NotFound -> #(
      model,
      modem.push("/404", option.None, option.None),
    )
    lustre_http.InternalServerError(_content) -> #(
      model,
      modem.push("/500", option.None, option.None),
    )
    e -> {
      io.debug(e)
      #(model, effect.none())
    }
  }
}
