import date
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/time/calendar
import pog

pub type Member {
  Member(hca_id: String, slack_id: String, birthdate: Option(calendar.Date))
}

pub fn to_member_input(member: Member) -> MemberInput {
  MemberInput(birthdate: member.birthdate)
}

pub type MemberInput {
  MemberInput(birthdate: Option(calendar.Date))
}

pub fn to_member(
  input: MemberInput,
  hca_id: String,
  slack_id: String,
) -> Member {
  Member(hca_id:, slack_id:, birthdate: input.birthdate)
}

pub fn member_decoder() -> Decoder(Member) {
  use hca_id <- decode.field("hca_id", decode.string)
  use slack_id <- decode.field("slack_id", decode.string)
  use birthdate <- decode.field(
    "birthdate",
    decode.optional(pog.calendar_date_decoder()),
  )
  decode.success(Member(hca_id:, slack_id:, birthdate:))
}

pub fn member_input_decoder() -> Decoder(MemberInput) {
  use birthdate <- decode.field(
    "birthdate",
    decode.optional(pog.calendar_date_decoder()),
  )
  decode.success(MemberInput(birthdate:))
}

pub fn member_to_json(member: Member) -> Json {
  let birthdate_json = case member.birthdate {
    None -> json.null()
    Some(date) -> date.calendar_date_to_json(date)
  }

  json.object([
    #("hca_id", json.string(member.hca_id)),
    #("slack_id", json.string(member.slack_id)),
    #("birthdate", birthdate_json),
  ])
}
