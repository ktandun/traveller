import frontend/api
import frontend/events.{type AppModel, type SignupPageEvent}
import frontend/web
import gleam/option
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import modem
import shared/auth_models

pub fn signup_view(model: AppModel) {
  html.div([], [
    html.h3([attribute.class("text-cursive")], [
      element.text("Signup to Traveller"),
    ]),
    html.div([], [
      html.label([], [element.text("Email")]),
      html.input([
        event.on_input(fn(input) {
          events.SignupPage(events.SignupPageUserUpdatedEmail(input))
        }),
        attribute.value(model.signup_request.email),
        attribute.name("email"),
        attribute.type_("email"),
      ]),
    ]),
    html.div([], [
      html.label([], [element.text("Password")]),
      html.input([
        event.on_input(fn(input) {
          events.SignupPage(events.SignupPageUserUpdatedPassword(input))
        }),
        attribute.value(model.signup_request.password),
        attribute.name("password"),
        attribute.type_("password"),
      ]),
    ]),
    html.button(
      [event.on_click(events.SignupPage(events.SignupPageUserClickedSubmit))],
      [element.text("Submit")],
    ),
  ])
}

pub fn handle_signup_page_event(model: AppModel, event: SignupPageEvent) {
  case event {
    events.SignupPageUserUpdatedEmail(email) -> #(
      events.AppModel(
        ..model,
        signup_request: auth_models.SignupRequest(
          ..model.signup_request,
          email:,
        ),
      ),
      effect.none(),
    )
    events.SignupPageUserUpdatedPassword(password) -> #(
      events.AppModel(
        ..model,
        signup_request: auth_models.SignupRequest(
          ..model.signup_request,
          password:,
        ),
      ),
      effect.none(),
    )
    events.SignupPageUserClickedSubmit -> #(
      events.AppModel(..model, show_loading: True),
      api.send_signup_request(model.signup_request),
    )
    events.SignupPageApiReturnedResponse(response) ->
      case response {
        Ok(_) -> #(
          events.AppModel(..model, show_loading: False),
          modem.push("/dashboard", option.None, option.None),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
  }
}
