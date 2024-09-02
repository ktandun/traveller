import env
import frontend/routes.{type Route}
import lustre_http.{type HttpError}
import shared/auth_models
import shared/id.{type Id, type TripId, type TripPlaceId, type UserId}
import shared/trip_models.{type UserTripCompanion}

pub type AppEvent {
  NoEvent
  OnRouteChange(Route)
  ShowToast
  HideToast
  // page specific events
  LoginPage(LoginPageEvent)
  TripsDashboardPage(TripsDashboardPageEvent)
  TripDetailsPage(TripDetailsPageEvent)
  TripCompanionsPage(TripCompanionsPageEvent)
  TripCreatePage(TripCreatePageEvent)
  TripUpdatePage(TripUpdatePageEvent)
  TripPlaceCreatePage(TripPlaceCreatePageEvent)
}

pub type AppModel {
  AppModel(
    route: Route,
    toast: Toast,
    show_loading: Bool,
    api_base_url: String,
    login_request: auth_models.LoginRequest,
    trips_dashboard: trip_models.UserTrips,
    trip_details: trip_models.UserTripPlaces,
    trip_create: trip_models.CreateTripRequest,
    trip_create_errors: String,
    trip_update: trip_models.UpdateTripRequest,
    trip_update_errors: String,
    trip_place_create: trip_models.CreateTripPlaceRequest,
    trip_place_create_errors: String,
  )
}

pub fn set_default_login_request(model: AppModel) {
  AppModel(..model, login_request: auth_models.default_login_request())
}

pub fn set_default_trip_place_create(model: AppModel) {
  AppModel(
    ..model,
    trip_place_create: trip_models.default_create_trip_place_request(),
    trip_place_create_errors: "",
  )
}

pub fn set_default_trip_create(model: AppModel) {
  AppModel(
    ..model,
    trip_create: trip_models.default_create_trip_request(),
    trip_create_errors: "",
  )
}

pub fn set_default_trip_update(model: AppModel) {
  AppModel(
    ..model,
    trip_update: trip_models.default_update_trip_request(),
    trip_update_errors: "",
  )
}

pub type Toast {
  Toast(visible: Bool, header: String, content: String)
}

pub fn default_app_model() {
  AppModel(
    route: routes.Login,
    toast: Toast(visible: False, header: "", content: ""),
    show_loading: False,
    api_base_url: env.api_base_url,
    login_request: auth_models.default_login_request(),
    trips_dashboard: trip_models.default_user_trips(),
    trip_details: trip_models.default_user_trip_places(),
    trip_create: trip_models.default_create_trip_request(),
    trip_create_errors: "",
    trip_update: trip_models.default_update_trip_request(),
    trip_update_errors: "",
    trip_place_create: trip_models.default_create_trip_place_request(),
    trip_place_create_errors: "",
  )
}

pub type LoginPageEvent {
  LoginPageUserUpdatedEmail(email: String)
  LoginPageUserUpdatedPassword(password: String)
  LoginPageUserClickedSubmit
  LoginPageApiReturnedResponse(Result(Id(UserId), HttpError))
}

pub type TripsDashboardPageEvent {
  TripsDashboardPageUserClickedCreateTripButton
  TripsDashboardPageApiReturnedTrips(Result(trip_models.UserTrips, HttpError))
}

pub type TripDetailsPageEvent {
  TripDetailsPageApiReturnedTripDetails(
    Result(trip_models.UserTripPlaces, HttpError),
  )
  TripDetailsPageUserClickedCreatePlace(trip_id: String)
  TripDetailsPageUserClickedUpdateTrip(trip_id: String)
  TripDetailsPageUserClickedAddCompanions(trip_id: String)
}

pub type TripCreatePageEvent {
  TripCreatePageUserInputCreateTripRequest(trip_models.CreateTripRequest)
  TripCreatePageUserClickedCreateTrip
  TripCreatePageApiReturnedResponse(Result(Id(TripId), HttpError))
}

pub type TripUpdatePageEvent {
  TripUpdatePageUserInputUpdateTripRequest(trip_models.UpdateTripRequest)
  TripUpdatePageUserClickedUpdateTrip(trip_id: String)
  TripUpdatePageApiReturnedResponse(Result(Id(TripId), HttpError))
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
  TripCompanionsPageApiReturnedResponse(trip_id: String, Result(Nil, HttpError))
}
