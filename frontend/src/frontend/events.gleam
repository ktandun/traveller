import frontend/routes.{type Route}
import gleam/dynamic.{type Dynamic}
import lustre_http.{type HttpError}
import shared/auth_models
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{type UserTripCompanion}

pub type AppEvent {
  OnRouteChange(Route)
  LoginPage(LoginPageEvent)
  TripsDashboardPage(TripsDashboardPageEvent)
  TripDetailsPage(TripDetailsPageEvent)
  TripCompanionsPage(TripCompanionsPageEvent)
  TripCreatePage(TripCreatePageEvent)
  TripPlaceCreatePage(TripPlaceCreatePageEvent)
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
    trip_place_create: trip_models.CreateTripPlaceRequest,
    trip_place_create_errors: String,
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
    trip_place_create: trip_models.default_create_trip_place_request(),
    trip_place_create_errors: "",
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
  TripDetailsPageUserClickedCreatePlace(trip_id: String)
  TripDetailsPageUserClickedAddCompanions(trip_id: String)
}

pub type TripCreatePageEvent {
  TripCreatePageUserInputCreateTripRequest(trip_models.CreateTripRequest)
  TripCreatePageUserClickedCreateTrip
  TripCreatePageApiReturnedResponse(Result(Id(TripId), HttpError))
}

pub type TripPlaceCreatePageEvent {
  TripPlaceCreatePageApiReturnedResponse(
    trip_id: String,
    Result(Id(TripPlaceId), HttpError),
  )
  TripPlaceCreatePageUserInputCreateTripPlaceRequest(
    trip_models.CreateTripPlaceRequest,
  )
  TripPlaceCreatePageUserClickedSubmit(trip_id: String)
}

pub type TripCompanionsPageEvent {
  TripCompanionsPageUserClickedRemoveCompanion(trip_companion_id: String)
  TripCompanionsPageUserUpdatedCompanion(UserTripCompanion)
  TripCompanionsPageUserClickedAddMoreCompanion
  TripCompanionsPageUserClickedSaveCompanions(trip_id: String)
  TripCompanionsPageApiReturnedResponse(
    trip_id: String,
    Result(Dynamic, HttpError),
  )
}
