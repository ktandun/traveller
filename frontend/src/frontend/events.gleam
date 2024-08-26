import frontend/routes.{type Route}
import shared/auth_models
import shared/id.{type Id, type UserId, type TripId}
import shared/trip_models
import lustre_http.{type HttpError}

pub type AppEvent {
  OnRouteChange(Route)
  LoginPage(LoginPageEvent)
  TripsDashboardPage(TripsDashboardPageEvent)
  TripDetailsPage(TripDetailsPageEvent)
  TripCreatePage(TripCreatePageEvent)
}

pub type AppModel {
  AppModel(
    route: Route,
    show_loading: Bool,
    login_request: auth_models.LoginRequest,
    trips_dashboard: trip_models.UserTrips,
    trip_details: trip_models.UserTripPlaces,
    trip_create: trip_models.CreateTripRequest,
    trip_create_errors: String,
  )
}

pub fn default_app_model() {
  AppModel(
    route: routes.Login,
    show_loading: False,
    login_request: auth_models.default_login_request(),
    trips_dashboard: trip_models.default_user_trips(),
    trip_details: trip_models.default_user_trip_places(),
    trip_create: trip_models.default_create_trip_request(),
    trip_create_errors: "",
  )
}

pub type LoginPageEvent {
  LoginPageUserUpdatedEmail(email: String)
  LoginPageUserUpdatedPassword(password: String)
  LoginPageUserClickedSubmit
  LoginPageApiReturnedResponse(Id(UserId))
}

pub type TripsDashboardPageEvent {
  TripsDashboardPageUserClickedCreateTripButton
  TripsDashboardPageApiReturnedTrips(trip_models.UserTrips)
}

pub type TripDetailsPageEvent {
  TripDetailsPageApiReturnedTripDetails(trip_models.UserTripPlaces)
  TripDetailsPageUserClickedRemovePlace(trip_place_id: String)
}

pub type TripCreatePageEvent {
  TripCreatePageUserInputCreateTripRequest(trip_models.CreateTripRequest)
  TripCreatePageUserClickedCreateTrip
  TripCreatePageApiReturnedResponse(Result(Id(TripId), HttpError))
}
