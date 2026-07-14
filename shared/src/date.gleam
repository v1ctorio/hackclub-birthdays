import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar.{type Date}

pub fn calendar_date_to_json(date: calendar.Date) -> Json {
  json.string(calendar_date_to_string(date))
}

pub fn calendar_date_to_string(date: Date) -> String {
  let month = case calendar.month_to_int(date.month) {
    m if m < 10 -> "0" <> int.to_string(m)
    m -> int.to_string(m)
  }
  let day = case date.day {
    d if d < 10 -> "0" <> int.to_string(d)
    d -> int.to_string(d)
  }

  int.to_string(date.year) <> "-" <> month <> "-" <> day
}

pub fn parse_calendar_date(s: String) -> Option(calendar.Date) {
  let parts = s |> string.split("-")
  case parts {
    [yeartext, monthtext, daytext] -> {
      case int.parse(yeartext), int.parse(monthtext), int.parse(daytext) {
        Ok(year), Ok(month), Ok(day) -> {
          case calendar.month_from_int(month) {
            Ok(month) -> {
              let date = calendar.Date(year:, month:, day:)
              case calendar.is_valid_date(date) {
                True -> Some(date)
                False -> None
              }
            }
            Error(_) -> None
          }
        }
        _, _, _ -> None
      }
    }
    _ -> None
  }
}

pub fn calendar_date_decoder() -> Decoder(Date) {
  decode.string
  |> decode.then(fn(value) {
    case parse_calendar_date(value) {
      Some(date) -> decode.success(date)
      None ->
        decode.failure(
          calendar.Date(0, calendar.January, 1),
          "ISO calendar date",
        )
    }
  })
}
