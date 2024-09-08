import frontend/events.{type AppEvent}
import gleam/option
import lustre/attribute.{type Attribute}
import lustre/element
import lustre/element/html
import lustre/event

fn form_input(
  label_text label: String,
  label_name name: String,
  attributes attributes: List(Attribute(AppEvent)),
) {
  html.div([], [
    html.label([], [element.text(label)]),
    html.input([attribute.name(name), ..attributes]),
    html.span([attribute.class("validity")], []),
  ])
}

pub fn date_input(
  label_text label: String,
  label_name name: String,
  required required: Bool,
  on_input input_handler: fn(String) -> events.AppEvent,
  value value: String,
  min min_value: option.Option(String),
  max max_value: option.Option(String),
) {
  form_input(label_text: label, label_name: name, attributes: [
    event.on_input(input_handler),
    attribute.type_("date"),
    attribute.required(required),
    attribute.value(value),
    case min_value {
      option.Some(min_value) -> attribute.min(min_value)
      _ -> attribute.none()
    },
    case max_value {
      option.Some(max_value) -> attribute.max(max_value)
      _ -> attribute.none()
    },
  ])
}

pub fn text_input(
  label_text label: String,
  label_name name: String,
  required required: Bool,
  on_input input_handler: fn(String) -> events.AppEvent,
  value value: String,
  placeholder placeholder: String,
) {
  form_input(label_text: label, label_name: name, attributes: [
    event.on_input(input_handler),
    attribute.type_("text"),
    attribute.required(required),
    attribute.value(value),
    attribute.placeholder(placeholder),
  ])
}

pub fn money_input(
  label_text label: String,
  label_name name: String,
  required required: Bool,
  on_input input_handler: fn(String) -> events.AppEvent,
  value value: String,
  placeholder placeholder: String,
) {
  form_input(label_text: label, label_name: name, attributes: [
    event.on_input(input_handler),
    attribute.step("0.01"),
    attribute.pattern("^\\d*(\\.\\d{0,2})?$"),
    attribute.type_("text"),
    attribute.required(required),
    attribute.value(value),
    attribute.placeholder(placeholder),
  ])
}

pub fn time_input(
  label_text label: String,
  label_name name: String,
  required required: Bool,
  on_input input_handler: fn(String) -> events.AppEvent,
  value value: String,
  placeholder placeholder: String,
) {
  form_input(label_text: label, label_name: name, attributes: [
    event.on_input(input_handler),
    attribute.type_("time"),
    attribute.required(required),
    attribute.value(value),
    attribute.placeholder(placeholder),
  ])
}

pub fn url_input(
  label_text label: String,
  label_name name: String,
  required required: Bool,
  on_input input_handler: fn(String) -> events.AppEvent,
  value value: String,
  placeholder placeholder: String,
) {
  form_input(label_text: label, label_name: name, attributes: [
    event.on_input(input_handler),
    attribute.type_("url"),
    attribute.required(required),
    attribute.value(value),
    attribute.placeholder(placeholder),
  ])
}
