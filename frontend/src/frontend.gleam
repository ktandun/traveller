import frontend/messages.{type Msg, type AppMsgModel}
import frontend/routes.{type Route}
import frontend/pages/login
import gleam/uri.{type Uri}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_) -> #(Route, Effect(Msg)) {

  #(routes.Login, modem.init(on_url_change))
}

fn on_url_change(uri: Uri) -> Msg {
  case uri.path_segments(uri.path) {
    ["login"] -> messages.OnRouteChange(routes.Login)
    ["signup"] -> messages.OnRouteChange(routes.Signup)
    _ -> messages.OnRouteChange(routes.FourOFour)
  }
}

fn update(model: AppMsgModel, msg: Msg) -> #(Route, Effect(Msg)) {
  case msg {
    messages.OnRouteChange(route) -> #(route, effect.none())
    messages.UserSubmitsLogin(email, password) -> #(model, login_user())
  }
}

fn view(route: Route) -> Element(Msg) {
  html.div([], [
    html.nav([], [
      html.a([attribute.href("/login")], [element.text("Go to login")]),
      html.a([attribute.href("/signup")], [element.text("Go to signup")]),
    ]),
    case route {
      routes.Login -> login.login_view()
      routes.Signup -> html.h1([], [element.text("Signup")])
      routes.FourOFour -> html.h1([], [element.text("Not Found")])
    },
  ])
}
