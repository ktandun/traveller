import gleam/uri.{type Uri}
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

pub fn login_view() {
  html.div([], [
    html.h1([], [element.text("Login")]),
    html.div([], [
      html.label([], [element.text("Email")]),
      html.input([attribute.name("email"), attribute.type_("email")]),
    ]),
    html.div([], [
      html.label([], [element.text("Password")]),
      html.input([attribute.name("password"), attribute.type_("password")]),
    ]),
    html.button([], [element.text("Submit")]),
  ])
}
