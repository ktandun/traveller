import birl
import gleam/int

pub fn day_to_string(day: birl.Day) {
  let year = day.year |> int.to_string
  let month = day.month |> int.to_string
  let day = day.date |> int.to_string

  year <> "-" <> month <> "-" <> day
}
