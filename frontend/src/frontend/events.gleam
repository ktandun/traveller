import frontend/routes.{type Route}
import shared/auth_models
import shared/id.{type Id, type UserId}

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
  LoginPageApiReturnedResponse(Id(UserId))
}

pub type TripsDashboardEvent {

}
