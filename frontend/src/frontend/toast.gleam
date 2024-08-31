import frontend/events.{type AppModel, AppModel}
import lustre/attribute
import lustre/element
import lustre/element/html

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
