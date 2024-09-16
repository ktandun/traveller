import frontend/events.{type AppModel}
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import lustre/attribute.{attribute}
import lustre/element.{text}
import lustre/element/html
import shared/date_util_shared
import shared/time_util_shared
import shared/trip_models

pub fn trip_summary_view(model: AppModel) {
  html.div([attribute.id("trip-details")], [
    html.article([], [
      html.header([], [
        html.h1([], [text("Trip to " <> model.trip_details.destination)]),
      ]),
      html.section([], [
        html.h2([], [text("Trip Summary")]),
        html.table([], [
          html.tbody([], [
            html.tr([], [
              html.th([], [text("Start Date")]),
              html.td([], [
                html.time([], [
                  text(
                    model.trip_details.start_date
                    |> date_util_shared.to_human_readable,
                  ),
                ]),
              ]),
            ]),
            html.tr([], [
              html.th([], [text("End Date")]),
              html.td([], [
                html.time([], [
                  text(
                    model.trip_details.end_date
                    |> date_util_shared.to_human_readable,
                  ),
                ]),
              ]),
            ]),
            html.tr([], [
              html.th([], [text("Total Activities Fee")]),
              html.td([], [
                text(model.trip_details.total_activities_fee |> float.to_string),
              ]),
            ]),
            html.tr([], [
              html.th([], [text("Total Accommodations Fee")]),
              html.td([], [
                text(
                  model.trip_details.total_accomodations_fee |> float.to_string,
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
      html.section([], [
        html.h2([], [text("Places of Interest and Activities")]),
        html.table([], [
          html.thead([], [
            html.tr([], [
              html.th([], [text("Place Name")]),
              html.th([], [text("Date")]),
              html.th([], [text("Accommodation")]),
              html.th([], [text("Activities")]),
              html.th([], [text("Culinaries")]),
            ]),
          ]),
          html.tbody(
            [],
            model.trip_details.user_trip_places
              |> list.map(fn(user_trip_place) {
                render_place_and_activity(user_trip_place)
              }),
          ),
        ]),
      ]),
      html.section([], [
        html.h2([], [text("Trip Companions")]),
        html.table([], [
          html.thead([], [
            html.tr([], [
              html.th([], [text("Companion Name")]),
              html.th([], [text("Email")]),
            ]),
          ]),
          html.tbody(
            [],
            model.trip_details.user_trip_companions
              |> list.map(fn(companion) { render_companion(companion) }),
          ),
        ]),
      ]),
    ]),
    html.mark([], [
      text("Generated with "),
      html.a([attribute.href("https://traveller.helpsme.work")], [
        text("https://traveller.helpsme.work"),
      ]),
    ]),
  ])
}

fn render_companion(model: trip_models.UserTripCompanion) {
  html.tr([], [
    html.td([], [text(model.name)]),
    html.td([], [
      html.a([attribute.href("mailto:" <> model.email)], [text(model.email)]),
    ]),
  ])
}

fn render_place_and_activity(model: trip_models.UserTripPlace) {
  html.tr([], [
    html.td([], [text(model.name)]),
    html.td([], [
      html.time([], [text(model.date |> date_util_shared.to_human_readable)]),
    ]),
    html.td([], case model.has_accomodation {
      True -> [
        html.p([], [text(model.accomodation_name |> option.unwrap(""))]),
        html.p([], case model.accomodation_information_url {
          option.Some(url) -> [
            html.a(
              [
                attribute.rel("noopener"),
                attribute.target("_blank"),
                attribute.href(url),
              ],
              [text("More Info")],
            ),
          ]
          option.None -> []
        }),
        html.p([], case model.accomodation_fee {
          option.Some(fee) -> [
            text(
              "Fee: "
              <> fee |> float.to_string
              <> " ("
              <> case model.accomodation_paid {
                False -> "Not paid"
                True -> "Paid"
              }
              <> ")",
            ),
          ]
          option.None -> []
        }),
      ]
      False -> []
    }),
    html.td([], [
      html.ul(
        [],
        model.activities
          |> list.map(fn(activity) {
            html.li([], [
              case activity.information_url {
                option.Some(url) ->
                  html.a(
                    [
                      attribute.rel("noopener"),
                      attribute.target("_blank"),
                      attribute.href(url),
                    ],
                    [text(activity.name)],
                  )
                option.None -> html.p([], [text(activity.name)])
              },
              html.p([], [
                text(
                  "Start: "
                  <> activity.start_time
                  |> option.map(time_util_shared.to_human_readable)
                  |> option.unwrap("n/a")
                  <> ", End: "
                  <> activity.end_time
                  |> option.map(time_util_shared.to_human_readable)
                  |> option.unwrap("n/a")
                  <> ", Fee: "
                  <> case activity.entry_fee {
                    option.Some(fee) -> fee |> float.to_string
                    option.None -> "n/a"
                  },
                ),
              ]),
            ])
          }),
      ),
    ]),
    html.td([], [
      html.ul(
        [],
        model.culinaries
          |> list.map(fn(culinary) {
            html.li([], [
              case culinary.information_url {
                option.Some(url) ->
                  html.a(
                    [
                      attribute.rel("noopener"),
                      attribute.target("_blank"),
                      attribute.href(url),
                    ],
                    [text(culinary.name)],
                  )
                option.None -> html.p([], [text(culinary.name)])
              },
              html.p([], [
                text(
                  "Open: "
                  <> culinary.open_time
                  |> option.map(time_util_shared.to_human_readable)
                  |> option.unwrap("n/a")
                  <> " - Close: "
                  <> culinary.close_time
                  |> option.map(time_util_shared.to_human_readable)
                  |> option.unwrap("n/a"),
                ),
              ]),
            ])
          }),
      ),
    ]),
  ])
}
