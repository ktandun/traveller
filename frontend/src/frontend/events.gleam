import frontend/routes.{type Route}
import shared/auth_models

pub type AppEvent {
  LoginPage(LoginPageEvent)
  OnRouteChange(Route)
}

pub type AppModel {
  AppModel(route: Route, login_request: auth_models.LoginRequest)
}

pub type LoginPageEvent {
  LoginPageUserUpdatedEmail(email: String)
  LoginPageUserUpdatedPassword(password: String)
  LoginPageUserClickedSubmit
  LoginPageApiReturnedResponse
}
