import gleam/int
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar.{Date}

pub fn calendar_date_to_json(date: calendar.Date) -> Json {
  json.string(
    int.to_string(date.year)
    <> "-"
    <> int.to_string(calendar.month_to_int(date.month))
    <> "-"
    <> int.to_string(date.day),
  )
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
