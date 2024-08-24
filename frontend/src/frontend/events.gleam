import frontend/routes.{type Route}
import shared/auth_models
import shared/id.{type Id, type UserId}
import shared/trip_models

pub type AppEvent {
  OnRouteChange(Route)
  LoginPage(LoginPageEvent)
  TripsDashboardPage(TripsDashboardPageEvent)
  TripDetailsPage(TripDetailsPageEvent)
}

pub type AppModel {
  AppModel(
    route: Route,
    login_request: auth_models.LoginRequest,
    trips_dashboard: trip_models.UserTrips,
    trip_details: trip_models.UserTripPlaces,
  )
}

pub fn default_app_model() {
  AppModel(
    route: routes.Login,
    login_request: auth_models.default_login_request(),
    trips_dashboard: trip_models.default_user_trips(),
    trip_details: trip_models.default_user_trip_places(),
  )
}

pub type LoginPageEvent {
  LoginPageUserUpdatedEmail(email: String)
  LoginPageUserUpdatedPassword(password: String)
  LoginPageUserClickedSubmit
  LoginPageApiReturnedResponse(Id(UserId))
}

pub type TripsDashboardPageEvent {
  TripsDashboardPageApiReturnedTrips(trip_models.UserTrips)
}

pub type TripDetailsPageEvent {
  TripDetailsPageApiReturnedTripDetails(trip_models.UserTripPlaces)
}
