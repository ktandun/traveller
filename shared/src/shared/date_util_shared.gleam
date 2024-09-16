import birl
import gleam/int
import gleam/result
import gleam/string

pub fn from_yyyy_mm_dd(date_str: String) -> Result(birl.Day, Nil) {
  case string.split(date_str, on: "-") {
    [yyyy, mm, dd] -> {
      use yyyy <- result.try(
        int.parse(yyyy)
        |> result.map_error(fn(_) { Nil }),
      )

      use mm <- result.try(
        int.parse(mm)
        |> result.map_error(fn(_) { Nil }),
      )

      use dd <- result.try(
        int.parse(dd)
        |> result.map_error(fn(_) { Nil }),
      )

      Ok(birl.Day(yyyy, mm, dd))
    }
    _ -> Error(Nil)
  }
}

pub fn to_human_readable(date: birl.Day) -> String {
  let birl.Day(year, month, day) = date

  let month = case int.to_string(month) {
    "1" -> "Jan"
    "2" -> "Feb"
    "3" -> "Mar"
    "4" -> "Apr"
    "5" -> "May"
    "6" -> "Jun"
    "7" -> "Jul"
    "8" -> "Aug"
    "9" -> "Sep"
    "10" -> "Oct"
    "11" -> "Nov"
    "12" -> "Dec"
    _ -> " "
  }

  month <> " " <> int.to_string(day) <> ", " <> int.to_string(year)
}

pub fn to_yyyy_mm_dd(date: birl.Day) -> String {
  let birl.Day(year, month, day) = date

  int.to_string(year)
  <> "-"
  <> int.to_string(month) |> string.pad_left(to: 2, with: "0")
  <> "-"
  <> int.to_string(day) |> string.pad_left(to: 2, with: "0")
}
