import gleam/string

/// from YYYY-MM-DD
pub fn to_human_readable(date: String) -> String {
  case date |> string.split("-") {
    [year, month, day] -> {
      let month = case month {
        "01" -> "Jan"
        "02" -> "Feb"
        "03" -> "Mar"
        "04" -> "Apr"
        "05" -> "May"
        "06" -> "Jun"
        "07" -> "Jul"
        "08" -> "Aug"
        "09" -> "Sep"
        "10" -> "Okt"
        "11" -> "Nov"
        "12" -> "Dec"
        _ -> ""
      }

      day <> " " <> month <> " " <> year
    }
    _ -> ""
  }
}
