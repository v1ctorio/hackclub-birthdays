import gleam/option.{type Option}
import gleam/time/calendar

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
