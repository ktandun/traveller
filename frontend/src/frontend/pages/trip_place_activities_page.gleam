import frontend/events.{
  type AppModel, type TripPlaceActivitiesPageEvent, AppModel,
}
import frontend/form_components
import frontend/web
import gleam/float
import gleam/list
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import shared/trip_models

pub fn trip_place_activities_view(
  model: AppModel,
  trip_id: String,
  trip_place_id: String,
) {
  html.div([], [
    html.h3([], [
      element.text("Activities in "),
      html.span([attribute.class("text-cursive")], [
        element.text(model.trip_place_activities.place_name),
      ]),
    ]),
    html.div(
      [],
      list.map(model.trip_place_activities.place_activities, fn(activity) {
        html.details([attribute.open(True)], [
          html.summary([], [element.text(activity.name)]),
          html.div([], [
            form_components.form_input(
              label_text: "Information URL",
              label_name: "information-url",
              required: False,
              field_type: "url",
              placeholder: "https://...",
              value: activity.information_url,
              on_input: fn(information_url) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    trip_models.PlaceActivity(..activity, information_url:),
                  ),
                )
              },
            ),
            form_components.form_input(
              label_text: "Start Time",
              label_name: "start-time",
              required: False,
              field_type: "time",
              placeholder: "",
              value: activity.start_time,
              on_input: fn(start_time) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    trip_models.PlaceActivity(..activity, start_time:),
                  ),
                )
              },
            ),
            form_components.form_input(
              label_text: "End Time",
              label_name: "end-time",
              required: False,
              field_type: "time",
              placeholder: "",
              value: activity.end_time,
              on_input: fn(end_time) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    trip_models.PlaceActivity(..activity, end_time:),
                  ),
                )
              },
            ),
            form_components.form_input(
              label_text: "Entry Fee",
              label_name: "entry-fee",
              required: False,
              field_type: "number",
              placeholder: "",
              value: float.to_string(activity.entry_fee),
              on_input: fn(entry_fee) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    trip_models.PlaceActivity(
                      ..activity,
                      entry_fee: case float.parse(entry_fee) {
                        Ok(entry_fee) -> entry_fee
                        Error(_) -> 0.0
                      },
                    ),
                  ),
                )
              },
            ),
          ]),
        ])
      }),
    ),
  ])
}

pub fn handle_trip_place_activities_page_event(
  model: AppModel,
  event: TripPlaceActivitiesPageEvent,
) {
  case event {
    events.TripPlaceActivitiesPageUserInputForm(form) -> #(
      AppModel(
        ..model,
        trip_place_activities: trip_models.PlaceActivities(
          ..model.trip_place_activities,
          place_activities: model.trip_place_activities.place_activities
            |> list.map(fn(activity) {
              case activity.place_activity_id == form.place_activity_id {
                True -> form
                False -> activity
              }
            }),
        ),
      ),
      effect.none(),
    )
    events.TripPlaceActivitiesPageApiReturnedActivities(response) ->
      case response {
        Ok(response) -> #(
          AppModel(..model, trip_place_activities: response),
          effect.none(),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
  }
}
