import frontend/events
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub fn form_input(
  label_text label: String,
  label_name name: String,
  required required: Bool,
  field_type type_: String,
  on_input input_handler: fn(String) -> events.AppEvent,
  value value: String,
  placeholder placeholder: String,
) {
  html.p([], [
    html.label([], [element.text(label)]),
    html.input([
      event.on_input(input_handler),
      attribute.name(name),
      attribute.type_(type_),
      attribute.required(required),
      attribute.value(value),
      attribute.placeholder(placeholder),
    ]),
    html.span([attribute.class("validity")], []),
  ])
}
