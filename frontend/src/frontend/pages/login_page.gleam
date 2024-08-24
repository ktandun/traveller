import decode
import frontend/events.{type AppEvent}
import frontend/routes
import gleam/io
import gleam/option
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import modem
import shared/auth_models
import shared/id

pub fn login_view(app_model: events.AppModel) {
  html.div([], [
    html.h3([attribute.class("text-cursive")], [element.text("Login")]),
    html.div([], [
      html.label([], [element.text("Email")]),
      html.input([
        event.on_input(fn(input) {
          events.LoginPage(events.LoginPageUserUpdatedEmail(input))
        }),
        attribute.value(app_model.login_request.email),
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
        attribute.value(app_model.login_request.password),
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

pub fn handle_login_page_event(
  model: events.AppModel,
  event: events.LoginPageEvent,
) {
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
      model,
      handle_submit_login(model.login_request),
    )
    events.LoginPageApiReturnedResponse(_user_id) -> #(
      model,
      modem.push("/dashboard", option.None, option.None),
    )
  }
}

fn handle_submit_login(
  login_request: auth_models.LoginRequest,
) -> Effect(AppEvent) {
  let url = "http://localhost:8080/api/login"

  let json = auth_models.login_request_encoder(login_request)

  lustre_http.post(
    url,
    json,
    lustre_http.expect_json(
      fn(response) { id.id_decoder() |> decode.from(response) },
      fn(result) {
        case result {
          Ok(user_id) ->
            events.LoginPage(events.LoginPageApiReturnedResponse(user_id))
          Error(_e) -> events.OnRouteChange(routes.Login)
        }
      },
    ),
  )
}
