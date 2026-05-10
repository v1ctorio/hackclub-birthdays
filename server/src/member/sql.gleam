//// This module contains the code to run the sql queries defined in
//// `./src/member/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/time/calendar.{type Date}
import gleam/time/timestamp.{type Timestamp}
import pog

/// A row you get from running the `all_members` query
/// defined in `./src/member/sql/all_members.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type AllMembersRow {
  AllMembersRow(slack_id: String, birthday: Option(Date))
}

/// Runs the `all_members` query
/// defined in `./src/member/sql/all_members.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn all_members(
  db: pog.Connection,
) -> Result(pog.Returned(AllMembersRow), pog.QueryError) {
  let decoder = {
    use slack_id <- decode.field(0, decode.string)
    use birthday <- decode.field(
      1,
      decode.optional(pog.calendar_date_decoder()),
    )
    decode.success(AllMembersRow(slack_id:, birthday:))
  }

  "SELECT 
    slack_id,
    birthday
FROM 
    members
ORDER BY birthday DESC"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_birthday` query
/// defined in `./src/member/sql/create_birthday.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateBirthdayRow {
  CreateBirthdayRow(
    hca_id: String,
    slack_id: String,
    birthday: Option(Date),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `create_birthday` query
/// defined in `./src/member/sql/create_birthday.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_birthday(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: Date,
) -> Result(pog.Returned(CreateBirthdayRow), pog.QueryError) {
  let decoder = {
    use hca_id <- decode.field(0, decode.string)
    use slack_id <- decode.field(1, decode.string)
    use birthday <- decode.field(
      2,
      decode.optional(pog.calendar_date_decoder()),
    )
    use created_at <- decode.field(3, pog.timestamp_decoder())
    use updated_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(CreateBirthdayRow(
      hca_id:,
      slack_id:,
      birthday:,
      created_at:,
      updated_at:,
    ))
  }

  "INSERT INTO members (hca_id, slack_id, birthday)
VALUES ($1, $2, $3)
RETURNING
    hca_id,
    slack_id,
    birthday,
    created_at,
    updated_at"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.calendar_date(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_birthday` query
/// defined in `./src/member/sql/delete_birthday.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_birthday(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM members 
WHERE hca_id = $1"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `update_birthday` query
/// defined in `./src/member/sql/update_birthday.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpdateBirthdayRow {
  UpdateBirthdayRow(
    hca_id: String,
    slack_id: String,
    birthday: Option(Date),
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}

/// Runs the `update_birthday` query
/// defined in `./src/member/sql/update_birthday.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_birthday(
  db: pog.Connection,
  arg_1: String,
  arg_2: Date,
) -> Result(pog.Returned(UpdateBirthdayRow), pog.QueryError) {
  let decoder = {
    use hca_id <- decode.field(0, decode.string)
    use slack_id <- decode.field(1, decode.string)
    use birthday <- decode.field(
      2,
      decode.optional(pog.calendar_date_decoder()),
    )
    use created_at <- decode.field(3, pog.timestamp_decoder())
    use updated_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(UpdateBirthdayRow(
      hca_id:,
      slack_id:,
      birthday:,
      created_at:,
      updated_at:,
    ))
  }

  "UPDATE members
SET 
    birthday = $2,
    updated_at = NOW()
WHERE hca_id = $1
RETURNING
    hca_id,
    slack_id,
    birthday,
    created_at,
    updated_at"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.calendar_date(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
