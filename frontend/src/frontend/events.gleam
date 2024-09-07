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
  TripPlaceActivitiesPage(TripPlaceActivitiesPageEvent)
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
    trip_create: CreateTripForm,
    trip_create_errors: String,
    trip_update: TripUpdateForm,
    trip_update_errors: String,
    trip_place_create: TripPlaceCreateForm,
    trip_place_create_errors: String,
    trip_place_activities: PlaceActivitiesForm,
  )
}

pub fn set_default_login_request(model: AppModel) {
  AppModel(..model, login_request: auth_models.default_login_request())
}

pub fn set_default_trip_place_create(model: AppModel) {
  AppModel(
    ..model,
    trip_place_create: default_trip_place_create_form(),
    trip_place_create_errors: "",
  )
}

pub fn set_default_trip_create(model: AppModel) {
  AppModel(
    ..model,
    trip_create: default_create_trip_form(),
    trip_create_errors: "",
  )
}

pub fn set_default_trip_update(model: AppModel) {
  AppModel(
    ..model,
    trip_update: default_trip_update_form(),
    trip_update_errors: "",
  )
}

pub type Toast {
  Toast(visible: Bool, header: String, content: String, status: ToastStatus)
}

pub type ToastStatus {
  Success
  Failed
}

pub fn default_app_model() {
  AppModel(
    route: routes.Login,
    toast: Toast(visible: False, header: "", content: "", status: Success),
    show_loading: False,
    api_base_url: env.api_base_url,
    login_request: auth_models.default_login_request(),
    trips_dashboard: trip_models.default_user_trips(),
    trip_details: trip_models.default_user_trip_places(),
    trip_create: default_create_trip_form(),
    trip_create_errors: "",
    trip_update: default_trip_update_form(),
    trip_update_errors: "",
    trip_place_create: default_trip_place_create_form(),
    trip_place_create_errors: "",
    trip_place_activities: default_trip_place_activities_form(),
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

pub type CreateTripForm {
  CreateTripForm(start_date: String, end_date: String, destination: String)
}

pub fn default_create_trip_form() {
  CreateTripForm(start_date: "", end_date: "", destination: "")
}

pub type TripCreatePageEvent {
  TripCreatePageUserInputCreateTripRequest(CreateTripForm)
  TripCreatePageUserClickedCreateTrip
  TripCreatePageApiReturnedResponse(Result(Id(TripId), HttpError))
}

pub type TripUpdateForm {
  TripUpdateForm(destination: String, start_date: String, end_date: String)
}

pub fn default_trip_update_form() {
  TripUpdateForm(destination: "", start_date: "", end_date: "")
}

pub type TripUpdatePageEvent {
  TripUpdatePageUserInputUpdateTripRequest(TripUpdateForm)
  TripUpdatePageUserClickedUpdateTrip(trip_id: String)
  TripUpdatePageApiReturnedResponse(Result(Id(TripId), HttpError))
}

pub type TripPlaceCreateForm {
  TripPlaceCreateForm(place: String, date: String)
}

pub fn default_trip_place_create_form() {
  TripPlaceCreateForm(place: "", date: "")
}

pub type TripPlaceCreatePageEvent {
  TripPlaceCreatePageApiReturnedResponse(
    trip_id: String,
    Result(Id(TripPlaceId), HttpError),
  )
  TripPlaceCreatePageUserInputCreateTripPlaceRequest(TripPlaceCreateForm)
  TripPlaceCreatePageUserClickedSubmit(trip_id: String)
}

pub type TripCompanionsPageEvent {
  TripCompanionsPageUserClickedRemoveCompanion(trip_companion_id: String)
  TripCompanionsPageUserUpdatedCompanion(UserTripCompanion)
  TripCompanionsPageUserClickedAddMoreCompanion
  TripCompanionsPageUserClickedSaveCompanions(trip_id: String)
  TripCompanionsPageApiReturnedResponse(trip_id: String, Result(Nil, HttpError))
}

pub type PlaceActivitiesForm {
  PlaceActivitiesForm(
    place_name: String,
    place_activities: List(PlaceActivityForm),
  )
}

pub type PlaceActivityForm {
  PlaceActivityForm(
    start_time: String,
    end_time: String,
    place_activity_id: String,
    name: String,
    information_url: String,
    entry_fee: String,
  )
}

pub fn default_trip_place_activity_form() {
  PlaceActivityForm(
    start_time: "",
    end_time: "",
    place_activity_id: "",
    name: "",
    information_url: "",
    entry_fee: "",
  )
}

pub fn default_trip_place_activities_form() {
  PlaceActivitiesForm(place_name: "", place_activities: [])
}

pub type TripPlaceActivitiesPageEvent {
  TripPlaceActivitiesPageApiReturnedActivities(
    Result(trip_models.PlaceActivities, HttpError),
  )
  TripPlaceActivitiesPageUserInputForm(PlaceActivityForm)
  TripPlaceActivitiesUserClickedAddMore
  TripPlaceActivitiesUserClickedSave(trip_id: String, trip_place_id: String)
  TripPlaceActivitiesPageApiReturnedSaveResponse(Result(Nil, HttpError))
}
