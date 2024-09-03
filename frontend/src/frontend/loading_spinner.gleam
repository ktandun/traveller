import frontend/events.{type AppModel, AppModel}
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn simple_loading_spinner(app_model: AppModel) {
  case app_model.show_loading {
    True ->
      html.div([attribute.class("loading-overlay")], [
        html.div([attribute.class("loading-screen")], [
          html.div([attribute.class("spinner")], []),
          html.p([], [element.text("Loading...")]),
        ]),
      ])
    False -> html.div([attribute.class("loading-screen-placeholder")], [])
  }
}

pub fn hide_loading_spinner(model: AppModel) {
  AppModel(..model, show_loading: False)
}
