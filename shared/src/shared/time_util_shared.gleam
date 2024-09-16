import gleam/string

pub fn to_human_readable(time_str: String) -> String {
  case string.split(time_str, ":") {
    [hour, min, ..] -> hour <> ":" <> min
    _ -> time_str
  }
}
