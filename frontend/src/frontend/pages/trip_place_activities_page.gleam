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
  _trip_id: String,
  _trip_place_id: String,
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
            form_components.url_input(
              label_text: "Information URL",
              label_name: "information-url",
              required: False,
              placeholder: "https://...",
              value: activity.information_url,
              on_input: fn(information_url) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    events.PlaceActivityForm(..activity, information_url:),
                  ),
                )
              },
            ),
            form_components.time_input(
              label_text: "Start Time",
              label_name: "start-time",
              required: False,
              placeholder: "",
              value: activity.start_time,
              on_input: fn(start_time) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    events.PlaceActivityForm(..activity, start_time:),
                  ),
                )
              },
            ),
            form_components.time_input(
              label_text: "End Time",
              label_name: "end-time",
              required: False,
              placeholder: "",
              value: activity.end_time,
              on_input: fn(end_time) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    events.PlaceActivityForm(..activity, end_time:),
                  ),
                )
              },
            ),
            form_components.money_input(
              label_text: "Entry Fee",
              label_name: "entry-fee",
              required: False,
              placeholder: "",
              value: activity.entry_fee,
              on_input: fn(entry_fee) {
                events.TripPlaceActivitiesPage(
                  events.TripPlaceActivitiesPageUserInputForm(
                    events.PlaceActivityForm(..activity, entry_fee:),
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
    events.TripPlaceActivitiesPageUserInputForm(activity_form) -> #(
      AppModel(
        ..model,
        trip_place_activities: events.PlaceActivitiesForm(
          ..model.trip_place_activities,
          place_activities: model.trip_place_activities.place_activities
            |> list.map(fn(activity) {
              case
                activity.place_activity_id == activity_form.place_activity_id
              {
                True -> activity_form
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
          AppModel(
            ..model,
            trip_place_activities: events.PlaceActivitiesForm(
              place_name: response.place_name,
              place_activities: list.map(
                response.place_activities,
                fn(activity) {
                  events.PlaceActivityForm(
                    start_time: activity.start_time,
                    end_time: activity.end_time,
                    place_activity_id: activity.place_activity_id,
                    name: activity.name,
                    information_url: activity.information_url,
                    entry_fee: activity.entry_fee |> float.to_string,
                  )
                },
              ),
            ),
          ),
          effect.none(),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
  }
}
