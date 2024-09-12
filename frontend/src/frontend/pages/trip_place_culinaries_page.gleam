import frontend/api
import frontend/events.{
  type AppModel, type TripPlaceCulinariesPageEvent, AppModel,
}
import frontend/form_components as fc
import frontend/toast
import frontend/uuid_util
import frontend/web
import gleam/float
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import shared/trip_models

pub fn trip_place_culinaries_view(
  model: AppModel,
  trip_id: String,
  trip_place_id: String,
) {
  let culinaries = model.trip_place_culinaries

  html.div([], [
    html.h3([], [
      element.text("Culinaries in "),
      html.span([attribute.class("text-cursive")], [
        element.text(culinaries.place_name),
      ]),
    ]),
    html.div([attribute.class("buttons")], [
      html.button(
        [
          attribute.disabled(model.show_loading),
          event.on_click(events.TripPlaceCulinariesPage(
            events.TripPlaceCulinariesPageUserClickedAddMore,
          )),
        ],
        [
          element.text(case culinaries.place_culinaries {
            [] -> "Add First Culinary Spot"
            _ -> "Add More"
          }),
        ],
      ),
      html.button(
        [
          attribute.disabled(model.show_loading),
          event.on_click(
            events.TripPlaceCulinariesPage(
              events.TripPlaceCulinariesPageUserClickedSave(
                trip_id,
                trip_place_id,
              ),
            ),
          ),
        ],
        [element.text("Save")],
      ),
    ]),
    html.div([], case list.is_empty(culinaries.place_culinaries) {
      True -> [
        html.p([attribute.class("notice")], [
          element.text(
            "No culinaries planned yet, create one using button above 👆",
          ),
        ]),
      ]
      False ->
        list.map(culinaries.place_culinaries, fn(culinary) {
          html.details([attribute.open(True)], [
            html.summary([], [
              element.text(case string.is_empty(culinary.name) {
                True -> "Unnamed"
                False -> culinary.name
              }),
            ]),
            html.div([attribute.class("inputs")], [
              fc.new()
                |> fc.with_label("Name")
                |> fc.with_required
                |> fc.with_value(culinary.name)
                |> fc.with_on_input(fn(name) {
                  events.TripPlaceCulinariesPage(
                    events.TripPlaceCulinariesPageUserInputForm(
                      events.PlaceCulinaryForm(..culinary, name:),
                    ),
                  )
                })
                |> fc.build,
              fc.new()
                |> fc.with_form_type(fc.UrlInput)
                |> fc.with_label("Information URL")
                |> fc.with_placeholder("https://...")
                |> fc.with_value(culinary.information_url)
                |> fc.with_on_input(fn(information_url) {
                  events.TripPlaceCulinariesPage(
                    events.TripPlaceCulinariesPageUserInputForm(
                      events.PlaceCulinaryForm(..culinary, information_url:),
                    ),
                  )
                })
                |> fc.build,
              fc.new()
                |> fc.with_form_type(fc.TimeInput)
                |> fc.with_label("Open Time")
                |> fc.with_value(culinary.open_time)
                |> fc.with_on_input(fn(open_time) {
                  events.TripPlaceCulinariesPage(
                    events.TripPlaceCulinariesPageUserInputForm(
                      events.PlaceCulinaryForm(..culinary, open_time:),
                    ),
                  )
                })
                |> fc.build,
              fc.new()
                |> fc.with_form_type(fc.TimeInput)
                |> fc.with_label("Close Time")
                |> fc.with_value(culinary.close_time)
                |> fc.with_on_input(fn(close_time) {
                  events.TripPlaceCulinariesPage(
                    events.TripPlaceCulinariesPageUserInputForm(
                      events.PlaceCulinaryForm(..culinary, close_time:),
                    ),
                  )
                })
                |> fc.build,
            ]),
          ])
        })
    }),
  ])
}

pub fn handle_trip_place_culinaries_page_event(
  model: AppModel,
  event: TripPlaceCulinariesPageEvent,
) {
  case event {
    events.TripPlaceCulinariesPageUserClickedSave(trip_id, trip_place_id) -> #(
      model,
      api.send_place_culinaries_update_request(
        trip_id,
        trip_place_id,
        trip_models.PlaceCulinaries(
          trip_id: trip_id,
          trip_place_id: trip_place_id,
          place_name: model.trip_place_culinaries.place_name,
          place_culinaries: model.trip_place_culinaries.place_culinaries
            |> list.map(fn(culinary) {
              trip_models.PlaceCulinary(
                place_culinary_id: culinary.place_culinary_id,
                name: culinary.name,
                information_url: case culinary.information_url {
                  "" -> option.None
                  _ -> option.Some(culinary.information_url)
                },
                open_time: case culinary.open_time {
                  "" -> option.None
                  _ -> option.Some(culinary.open_time)
                },
                close_time: case culinary.close_time {
                  "" -> option.None
                  _ -> option.Some(culinary.close_time)
                },
              )
            }),
        ),
      ),
    )
    events.TripPlaceCulinariesPageUserClickedAddMore -> #(
      AppModel(
        ..model,
        trip_place_culinaries: events.PlaceCulinariesForm(
          ..model.trip_place_culinaries,
          place_culinaries: [
            events.default_place_culinary_form(),
            ..model.trip_place_culinaries.place_culinaries
          ],
        ),
      ),
      effect.none(),
    )
    events.TripPlaceCulinariesPageUserInputForm(form) -> #(
      AppModel(
        ..model,
        trip_place_culinaries: events.PlaceCulinariesForm(
          ..model.trip_place_culinaries,
          place_culinaries: model.trip_place_culinaries.place_culinaries
            |> list.map(fn(culinary) {
              case culinary.place_culinary_id == form.place_culinary_id {
                True -> form
                False -> culinary
              }
            }),
        ),
      ),
      effect.none(),
    )
    events.TripPlaceCulinariesPageApiReturnedCulinaries(response) ->
      case response {
        Ok(response) -> #(
          model
            |> events.set_hide_loading()
            |> events.set_trip_place_culinaries(events.PlaceCulinariesForm(
              trip_id: response.trip_id,
              trip_place_id: response.trip_place_id,
              place_name: response.place_name,
              place_culinaries: response.place_culinaries
                |> list.map(fn(culinary) {
                  events.PlaceCulinaryForm(
                    place_culinary_id: culinary.place_culinary_id,
                    name: culinary.name,
                    open_time: culinary.open_time |> option.unwrap(""),
                    close_time: culinary.close_time |> option.unwrap(""),
                    information_url: culinary.information_url
                      |> option.unwrap(""),
                  )
                }),
            )),
          effect.none(),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
    events.TripPlaceCulinariesPageApiReturnedSaveResponse(response) ->
      case response {
        Ok(_) -> #(
          model
            |> events.set_hide_loading()
            |> toast.set_success_toast(content: "Culinaries updated"),
          effect.batch([
            effect.from(fn(dispatch) { dispatch(events.ShowToast) }),
          ]),
        )
        Error(e) -> web.error_to_app_event(e, model)
      }
  }
}
