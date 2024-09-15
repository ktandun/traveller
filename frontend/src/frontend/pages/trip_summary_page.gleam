import frontend/events.{type AppModel}
import gleam/float
import lustre/attribute
import lustre/element
import lustre/element/html
import shared/date_util_shared

pub fn trip_summary_view(model: AppModel) {
  html.div([], [
    html.h2([], [
      element.text("Trip to "),
      html.span([attribute.class("text-cursive")], [
        element.text(model.trip_details.destination),
      ]),
    ]),
    html.div([], [
      html.dl([], [
        html.dt([], [element.text("Dates")]),
        html.dd([], [
          element.text(
            date_util_shared.to_human_readable(model.trip_details.start_date)
            <> " to "
            <> date_util_shared.to_human_readable(model.trip_details.end_date),
          ),
        ]),
        html.dt([], [element.text("Activity Fee")]),
        html.dd([], [
          element.text(
            model.trip_details.total_activities_fee |> float.to_string,
          ),
        ]),
        html.dt([], [element.text("Accomodations Fee")]),
        html.dd([], [
          element.text(
            model.trip_details.total_accomodations_fee |> float.to_string,
          ),
        ]),
      ]),
    ]),
  ])
}
