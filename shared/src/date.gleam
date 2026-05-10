import gleam/int
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar.{Date}

pub fn calendar_date_to_json(date: calendar.Date) -> Json {
  // I hate like really hate having to do this but i guess it's what i should do (padding the strings like this)
  let month = case calendar.month_to_int(date.month) {
    m if m < 10 -> "0" <> int.to_string(m)
    m -> int.to_string(m)
  }
  let day = case date.day {
    d if d < 10 -> "0" <> int.to_string(d)
    d -> int.to_string(d)
  }

  json.string(int.to_string(date.year) <> "-" <> month <> "-" <> day)
}

pub fn json_to_calendar_date(j: Json) -> Option(calendar.Date) {
  j |> json.to_string |> parse_calendar_date()
}

pub fn parse_calendar_date(s: String) -> Option(calendar.Date) {
  let parts = s |> string.split("-")
  case parts {
    [yeartext, monthtext, daytext] -> {
      case
        [
          int.parse(yeartext),
          int.parse(monthtext),
          int.parse(daytext),
        ]
      {
        [Ok(year), Ok(month), Ok(day)] -> {
          case calendar.month_from_int(month) {
            Ok(month) -> option.Some(calendar.Date(year:, month:, day:))
            Error(_) -> option.None
          }
        }
        _ -> option.None
      }
    }
    _ -> option.None
  }
}
