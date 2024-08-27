import birl
import gleam/int
import gleam/result
import gleam/string
import traveller/error.{type AppError}

pub fn from_yyyy_mm_dd(date_str: String) -> Result(#(Int, Int, Int), AppError) {
  case string.split(date_str, on: "-") {
    [yyyy, mm, dd] -> {
      use yyyy <- result.try(
        int.parse(yyyy)
        |> result.map_error(fn(_) { error.InvalidDateSpecified }),
      )

      use mm <- result.try(
        int.parse(mm)
        |> result.map_error(fn(_) { error.InvalidDateSpecified }),
      )

      use dd <- result.try(
        int.parse(dd)
        |> result.map_error(fn(_) { error.InvalidDateSpecified }),
      )

      Ok(#(yyyy, mm, dd))
    }
    _ -> Error(error.InvalidDateSpecified)
  }
}

pub fn is_date_within(
  date: String,
  start from: String,
  end to: String,
) -> Result(Bool, AppError) {
  let now = birl.now()

  use #(year, month, date) <- result.try(from_yyyy_mm_dd(date))
  use #(start_year, start_month, start_date) <- result.try(from_yyyy_mm_dd(from))
  use #(end_year, end_month, end_date) <- result.try(from_yyyy_mm_dd(to))

  let date = birl.set_day(now, birl.Day(year, month, date))
  let start_date =
    birl.set_day(now, birl.Day(start_year, start_month, start_date))
  let end_date = birl.set_day(now, birl.Day(end_year, end_month, end_date))

  Ok(
    birl.to_unix(start_date) <= birl.to_unix(date)
    && birl.to_unix(date) <= birl.to_unix(end_date),
  )
}
