import gleam/string
import traveller/error.{type AppError}

pub fn string_not_empty(
  str: String,
  field_name: String,
) -> Result(Nil, AppError) {
  case string.is_empty(string.trim(str)) {
    True -> Error(error.ValidationFailed(field_name))
    False -> Ok(Nil)
  }
}
