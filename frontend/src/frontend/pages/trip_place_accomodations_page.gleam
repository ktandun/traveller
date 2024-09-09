import frontend/api
import frontend/events.{
  type AppModel, type TripPlaceActivitiesPageEvent, AppModel,
}
import frontend/form_components
import frontend/string_util
import frontend/toast
import frontend/web
import gleam/float
import gleam/function
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import shared/trip_models

pub fn trip_place_accomodations_view(
  model: AppModel,
  trip_id: String,
  trip_place_id: String,
) {
}

pub fn handle_trip_place_accomodations_page_event(
  model: AppModel,
  event: TripPlaceActivitiesPageEvent,
) {
  todo
}
