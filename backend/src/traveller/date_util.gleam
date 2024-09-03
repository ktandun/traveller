import birl
import gleam/result
import shared/date_util_shared
import traveller/error.{type AppError}

pub fn from_date_tuple(date: #(Int, Int, Int)) -> birl.Day {
  let #(year, mon, day) = date
  birl.Day(year, mon, day)
}

pub fn from_yyyy_mm_dd(date_str: String) -> Result(birl.Day, AppError) {
  date_util_shared.from_yyyy_mm_dd(date_str)
  |> result.map_error(fn(_) { error.InvalidDateSpecified })
}

pub fn is_date_within(
  date: birl.Day,
  start from: birl.Day,
  end to: birl.Day,
) -> Bool {
  is_before(from, date) && is_before(date, to)
}

pub fn is_before(start from: birl.Day, end to: birl.Day) -> Bool {
  let now = birl.now() |> birl.set_time_of_day(birl.TimeOfDay(0, 0, 0, 0))

  let start_date = birl.set_day(now, from)
  let end_date = birl.set_day(now, to)

  birl.to_unix(start_date) <= birl.to_unix(end_date)
}
