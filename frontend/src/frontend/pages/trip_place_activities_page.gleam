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
    html.div([attribute.class("buttons")], [
      html.button(
        [
          event.on_click(events.TripPlaceActivitiesPage(
            events.TripPlaceActivitiesUserClickedAddMore,
          )),
        ],
        [
          element.text(case
            list.is_empty(model.trip_place_activities.place_activities)
          {
            True -> "Add First Activity"
            False -> "Add More"
          }),
        ],
      ),
      html.button(
        [
          event.on_click(
            events.TripPlaceActivitiesPage(
              events.TripPlaceActivitiesUserClickedSave(trip_id, trip_place_id),
            ),
          ),
        ],
        [element.text("Save")],
      ),
    ]),
    html.div([], case
      list.is_empty(model.trip_place_activities.place_activities)
    {
      True -> [
        html.p([attribute.class("notice")], [
          element.text("No activities yet, create one using button above 👆"),
        ]),
      ]
      False ->
        list.map(model.trip_place_activities.place_activities, fn(activity) {
          html.details([attribute.open(True)], [
            html.summary([attribute.class("summary-title")], [
              html.span([], [element.text(activity.name)]),
              html.span([], [element.text(activity.start_time)]),
            ]),
            html.div([attribute.class("inputs")], [
              form_components.text_input(
                label_text: "Name",
                label_name: "name",
                required: True,
                placeholder: "Fun activity",
                value: activity.name,
                on_input: fn(name) {
                  events.TripPlaceActivitiesPage(
                    events.TripPlaceActivitiesPageUserInputForm(
                      events.PlaceActivityForm(..activity, name:),
                    ),
                  )
                },
              ),
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
                      events.PlaceActivityForm(
                        ..activity,
                        entry_fee: case string.contains(entry_fee, ".") {
                          True -> entry_fee
                          False -> entry_fee <> ".0"
                        },
                      ),
                    ),
                  )
                },
              ),
            ]),
          ])
        })
    }),
  ])
}

pub fn handle_trip_place_activities_page_event(
  model: AppModel,
  event: TripPlaceActivitiesPageEvent,
) {
  case event {
    events.TripPlaceActivitiesUserClickedAddMore -> #(
      AppModel(
        ..model,
        trip_place_activities: events.PlaceActivitiesForm(
          ..model.trip_place_activities,
          place_activities: [
            events.default_trip_place_activity_form(),
            ..model.trip_place_activities.place_activities
          ],
        ),
      ),
      effect.none(),
    )
    events.TripPlaceActivitiesUserClickedSave(trip_id, trip_place_id) -> #(
      model,
      api.send_place_activities_update_request(
        trip_id,
        trip_place_id,
        trip_models.PlaceActivities(
          trip_id:,
          trip_place_id:,
          place_name: model.trip_place_activities.place_name,
          place_activities: list.map(
            model.trip_place_activities.place_activities,
            fn(activity) {
              trip_models.PlaceActivity(
                place_activity_id: activity.place_activity_id,
                name: activity.name,
                information_url: string.to_option(activity.information_url),
                start_time: string.to_option(activity.start_time),
                end_time: string.to_option(activity.end_time),
                entry_fee: case float.parse(activity.entry_fee) {
                  Ok(entry_fee) -> option.Some(entry_fee)
                  Error(_) -> option.None
                },
              )
            },
          ),
        ),
      ),
    )
    events.TripPlaceActivitiesPageApiReturnedSaveResponse(response) ->
      case response {
        Ok(_) -> #(
          model |> toast.set_success_toast(content: "Activities updated"),
          effect.batch([
            effect.from(fn(dispatch) { dispatch(events.ShowToast) }),
          ]),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
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
                    start_time: string_util.option_to_empty_string(
                      activity.start_time,
                      function.identity,
                    ),
                    end_time: string_util.option_to_empty_string(
                      activity.end_time,
                      function.identity,
                    ),
                    place_activity_id: activity.place_activity_id,
                    name: activity.name,
                    information_url: string_util.option_to_empty_string(
                      activity.information_url,
                      function.identity,
                    ),
                    entry_fee: string_util.option_to_empty_string(
                      activity.entry_fee,
                      float.to_string,
                    ),
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
