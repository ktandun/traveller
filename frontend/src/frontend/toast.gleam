import frontend/events.{type AppModel, AppModel, Toast}
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import plinth/javascript/global

pub fn simple_toast(show: Bool, header: String, content: String) {
  html.div(
    [
      attribute.class(
        "toast "
        <> case show {
          True -> "show"
          False -> ""
        },
      ),
    ],
    [
      html.div([attribute.class("toast-header")], [element.text(header)]),
      html.div([attribute.class("toast-content")], [element.text(content)]),
    ],
  )
}

pub fn show_toast(model: AppModel) {
  #(
    AppModel(..model, toast: Toast(..model.toast, visible: True)),
    effect.from(fn(dispatch) {
      global.set_timeout(2500, fn() { dispatch(events.HideToast) })
      Nil
    }),
  )
}

pub fn hide_toast(model: AppModel) {
  #(
    AppModel(..model, toast: Toast(..model.toast, visible: False)),
    effect.none(),
  )
}

pub fn set_success_toast(model: AppModel, content content: String) {
  AppModel(
    ..model,
    toast: events.Toast(..model.toast, header: "Success ✓", content:),
  )
}

pub fn set_failed_toast(model: AppModel, content content: String) {
  AppModel(
    ..model,
    toast: events.Toast(..model.toast, header: "Failed :(", content:),
  )
}

pub fn set_form_validation_failed_toast(model: AppModel) {
  AppModel(
    ..model,
    toast: events.Toast(
      ..model.toast,
      header: "Invalid data",
      content: "Some fields have invalid data",
    ),
  )
}
