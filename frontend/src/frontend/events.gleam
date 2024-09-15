import env
import frontend/routes.{type Route}
import frontend/uuid_util
import gleam/list
import gleam/result
import lustre_http.{type HttpError}
import shared/auth_models
import shared/date_util_shared
import shared/id.{type Id, type TripId, type TripPlaceId}
import shared/trip_models.{type UserTripCompanion}

pub type AppEvent {
  NoEvent
  OnRouteChange(Route)
  LogoutClicked
  LogoutApiReturnedResponse
  ShowToast
  HideToast
  // page specific events
  LoginPage(LoginPageEvent)
  SignupPage(SignupPageEvent)
  TripCompanionsPage(TripCompanionsPageEvent)
  TripCreatePage(TripCreatePageEvent)
  TripDetailsPage(TripDetailsPageEvent)
  TripPlaceAccomodationPage(TripPlaceAccomodationPageEvent)
  TripPlaceActivitiesPage(TripPlaceActivitiesPageEvent)
  TripPlaceCreatePage(TripPlaceCreatePageEvent)
  TripPlaceCulinariesPage(TripPlaceCulinariesPageEvent)
  TripPlaceUpdatePage(TripPlaceUpdatePageEvent)
  TripUpdatePage(TripUpdatePageEvent)
  TripsDashboardPage(TripsDashboardPageEvent)
}

pub type AppModel {
  AppModel(
    route: Route,
    toast: Toast,
    show_loading: Bool,
    api_base_url: String,
    login_request: auth_models.LoginRequest,
    signup_request: auth_models.SignupRequest,
    trips_dashboard: trip_models.UserTrips,
    trip_details: trip_models.UserTripPlaces,
    trip_create: CreateTripForm,
    trip_create_errors: String,
    trip_update: TripUpdateForm,
    trip_update_errors: String,
    trip_place_create: TripPlaceCreateForm,
    trip_place_create_errors: String,
    trip_place_update: TripPlaceUpdateForm,
    trip_place_update_errors: String,
    trip_place_activities: PlaceActivitiesForm,
    trip_place_accomodation: PlaceAccomodationForm,
    trip_place_culinaries: PlaceCulinariesForm,
  )
}

pub fn set_show_loading(model: AppModel) {
  AppModel(..model, show_loading: True)
}

pub fn set_hide_loading(model: AppModel) {
  AppModel(..model, show_loading: False)
}

pub fn set_trip_place_accomodation(model: AppModel, trip_place_accomodation) {
  AppModel(..model, trip_place_accomodation:)
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

pub fn set_default_trip_place_update(model: AppModel) {
  AppModel(
    ..model,
    trip_place_update: default_trip_place_update_form(),
    trip_place_update_errors: "",
  )
}

pub fn set_trip_place_update_form_from_place_details(model: AppModel) {
  let trip_place_update_form = case model.route {
    routes.TripPlaceUpdate(_trip_id, trip_place_id) ->
      model.trip_details.user_trip_places
      |> list.find_map(fn(place) {
        case place.trip_place_id == trip_place_id {
          True ->
            Ok(TripPlaceUpdateForm(
              place: place.name,
              date: place.date |> date_util_shared.to_yyyy_mm_dd,
            ))
          False -> Error(Nil)
        }
      })
      |> result.unwrap(default_trip_place_update_form())
    _ -> default_trip_place_update_form()
  }

  AppModel(..model, trip_place_update: trip_place_update_form)
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

pub fn set_trip_place_culinaries(model: AppModel, trip_place_culinaries) {
  AppModel(..model, trip_place_culinaries:)
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
    signup_request: auth_models.default_signup_request(),
    trips_dashboard: trip_models.default_user_trips(),
    trip_details: trip_models.default_user_trip_places(),
    trip_create: default_create_trip_form(),
    trip_create_errors: "",
    trip_update: default_trip_update_form(),
    trip_update_errors: "",
    trip_place_create: default_trip_place_create_form(),
    trip_place_create_errors: "",
    trip_place_update: default_trip_place_update_form(),
    trip_place_update_errors: "",
    trip_place_activities: default_trip_place_activities_form(),
    trip_place_accomodation: default_place_accomodation_form(),
    trip_place_culinaries: default_place_culinaries_form(),
  )
}

pub type LoginPageEvent {
  LoginPageUserUpdatedEmail(email: String)
  LoginPageUserUpdatedPassword(password: String)
  LoginPageUserClickedSubmit
  LoginPageApiReturnedResponse(Result(Nil, HttpError))
}

pub type SignupPageEvent {
  SignupPageUserUpdatedEmail(email: String)
  SignupPageUserUpdatedPassword(password: String)
  SignupPageUserClickedSubmit
  SignupPageApiReturnedResponse(Result(Nil, HttpError))
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

pub type TripPlaceUpdateForm {
  TripPlaceUpdateForm(place: String, date: String)
}

pub fn default_trip_place_update_form() {
  TripPlaceUpdateForm(place: "", date: "")
}

pub type TripPlaceUpdatePageEvent {
  TripPlaceUpdatePageOnLoad
  TripPlaceUpdatePageApiReturnedResponse(
    trip_id: String,
    Result(Id(TripPlaceId), HttpError),
  )
  TripPlaceUpdatePageUserInputUpdateTripPlaceRequest(TripPlaceUpdateForm)
  TripPlaceUpdatePageUserClickedSubmit(trip_id: String, trip_place_id: String)
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
    place_activity_id: String,
    name: String,
    start_time: String,
    end_time: String,
    information_url: String,
    entry_fee: String,
  )
}

pub fn default_trip_place_activity_form() {
  PlaceActivityForm(
    place_activity_id: uuid_util.gen_uuid(),
    name: "",
    start_time: "",
    end_time: "",
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

pub type PlaceAccomodationForm {
  PlaceAccomodationForm(
    place_accomodation_id: String,
    place_name: String,
    accomodation_name: String,
    information_url: String,
    accomodation_fee: String,
    paid: Bool,
  )
}

pub fn default_place_accomodation_form() {
  PlaceAccomodationForm(
    place_accomodation_id: "",
    place_name: "",
    accomodation_name: "",
    information_url: "",
    accomodation_fee: "",
    paid: False,
  )
}

pub type TripPlaceAccomodationPageEvent {
  TripPlaceAccomodationPageApiReturnedAccomodation(
    Result(trip_models.PlaceAccomodation, HttpError),
  )
  TripPlaceAccomodationPageUserInputForm(PlaceAccomodationForm)
  TripPlaceAccomodationPageUserClickedSave(
    trip_id: String,
    trip_place_id: String,
  )
  TripPlaceAccomodationPageApiReturnedSaveResponse(Result(Nil, HttpError))
}

pub fn default_place_culinaries_form() {
  PlaceCulinariesForm(
    trip_id: "",
    trip_place_id: "",
    place_name: "",
    place_culinaries: [],
  )
}

pub fn default_place_culinary_form() {
  PlaceCulinaryForm(
    place_culinary_id: uuid_util.gen_uuid(),
    name: "",
    information_url: "",
    open_time: "",
    close_time: "",
  )
}

pub type PlaceCulinariesForm {
  PlaceCulinariesForm(
    trip_id: String,
    trip_place_id: String,
    place_name: String,
    place_culinaries: List(PlaceCulinaryForm),
  )
}

pub type PlaceCulinaryForm {
  PlaceCulinaryForm(
    place_culinary_id: String,
    name: String,
    information_url: String,
    open_time: String,
    close_time: String,
  )
}

pub type TripPlaceCulinariesPageEvent {
  TripPlaceCulinariesPageApiReturnedCulinaries(
    Result(trip_models.PlaceCulinaries, HttpError),
  )
  TripPlaceCulinariesPageUserInputForm(PlaceCulinaryForm)
  TripPlaceCulinariesPageUserClickedAddMore
  TripPlaceCulinariesPageUserClickedSave(trip_id: String, trip_place_id: String)
  TripPlaceCulinariesPageApiReturnedSaveResponse(Result(Nil, HttpError))
}
