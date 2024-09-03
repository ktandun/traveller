import birl
import gleam/int
import gleam/regex
import gleam/result
import gleam/string
import toy

pub fn day_decoder(field_name: String) {
  toy.string
  |> toy.try_map(birl.Day(year: 1, month: 1, date: 1), fn(val) {
    case string.split(val, "-") {
      [year, month, date] ->
        {
          use year <- result.try(int.parse(year))
          use month <- result.try(int.parse(month))
          use date <- result.try(int.parse(date))

          Ok(birl.Day(year:, month:, date:))
        }
        |> result.replace_error([
          toy.ToyError(toy.InvalidType("birl.Day", val), []),
        ])
      _ ->
        Error([
          toy.ToyError(toy.ValidationFailed(field_name, "birl.Day", val), []),
        ])
    }
  })
}

pub fn uuid_decoder(field_name: String) {
  toy.string
  |> toy.try_map("", fn(val) {
    case string.split(val, "-") {
      [_a, _b, _c, _d, _e] ->
        {
          let assert Ok(re) =
            regex.from_string(
              "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
            )

          case regex.check(with: re, content: val) {
            True -> Ok(val)
            False -> Error(Nil)
          }
        }
        |> result.replace_error([toy.ToyError(toy.InvalidType("uuid", val), [])])
      _ ->
        Error([toy.ToyError(toy.ValidationFailed(field_name, "uuid", val), [])])
    }
  })
}
