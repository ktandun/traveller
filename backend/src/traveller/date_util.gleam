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
