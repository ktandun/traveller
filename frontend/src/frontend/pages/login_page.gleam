import frontend/api
import frontend/events.{type AppModel, type LoginPageEvent}
import frontend/web
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/auth_models

pub fn login_view(model: AppModel) {
  html.div([], [
    html.h3([attribute.class("text-cursive")], [element.text("Login")]),
    html.div([], [
      html.label([], [element.text("Email")]),
      html.input([
        event.on_input(fn(input) {
          events.LoginPage(events.LoginPageUserUpdatedEmail(input))
        }),
        attribute.value(model.login_request.email),
        attribute.name("email"),
        attribute.type_("email"),
      ]),
    ]),
    html.div([], [
      html.label([], [element.text("Password")]),
      html.input([
        event.on_input(fn(input) {
          events.LoginPage(events.LoginPageUserUpdatedPassword(input))
        }),
        attribute.value(model.login_request.password),
        attribute.name("password"),
        attribute.type_("password"),
      ]),
    ]),
    html.button(
      [event.on_click(events.LoginPage(events.LoginPageUserClickedSubmit))],
      [element.text("Submit")],
    ),
  ])
}

pub fn handle_login_page_event(model: AppModel, event: LoginPageEvent) {
  case event {
    events.LoginPageUserUpdatedEmail(email) -> #(
      events.AppModel(
        ..model,
        login_request: auth_models.LoginRequest(..model.login_request, email:),
      ),
      effect.none(),
    )
    events.LoginPageUserUpdatedPassword(password) -> #(
      events.AppModel(
        ..model,
        login_request: auth_models.LoginRequest(
          ..model.login_request,
          password:,
        ),
      ),
      effect.none(),
    )
    events.LoginPageUserClickedSubmit -> #(
      events.AppModel(..model, show_loading: True),
      api.send_login_request(model.login_request),
    )
    events.LoginPageApiReturnedResponse(response) ->
      case response {
        Ok(_) -> #(
          events.AppModel(..model, show_loading: False),
          modem.push("/dashboard", option.None, option.None),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
  }
}
