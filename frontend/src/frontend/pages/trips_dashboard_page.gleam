import decode
import frontend/events
import frontend/routes
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import shared/auth_models
import shared/id

pub fn trips_dashboard_view(app_model: events.AppModel) {
  html.div([], [
    html.h1([], [element.text("Trips")])
  ])
}
