import gleam/option.{type Option}

pub fn option_to_empty_string(
  s: Option(a),
  to_string: fn(a) -> String,
) -> String {
  case s {
    option.Some(s) -> s |> to_string
    _ -> ""
  }
}
