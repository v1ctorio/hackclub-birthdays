import gleam/bool
import gleam/list
import gleam/option.{Some}
import gleam/result
import member/sql
import pog

import error.{type DatabaseError, QueryError, RecordNotFound, UnexpectedNoRows}
import member.{type Member, type MemberInput, Member}

pub fn all_members(
  db_conn: pog.Connection,
) -> Result(List(Member), error.DatabaseError) {
  let query_result =
    db_conn
    |> sql.all_members
    |> result.map_error(error.QueryError)
  use pog.Returned(_, rows) <- result.map(query_result)
  use row <- list.map(rows)

  Member(hca_id: row.hca_id, slack_id: row.slack_id, birthdate: row.birthdate)
}

pub fn create_member(
  db_conn: pog.Connection,
  input: MemberInput,
  hca_id: String,
  slack_id: String,
) -> Result(Member, DatabaseError) {
  //TODO handle the case in which there is no birthday provided
  let assert Some(birthdate) = input.birthdate
  let query_result =
    sql.create_birthday(db_conn, hca_id, slack_id, birthdate)
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(UnexpectedNoRows)
  use row <- result.map(row)

  Member(hca_id: row.hca_id, slack_id: row.slack_id, birthdate: row.birthdate)
}

pub fn get_member(
  db_conn: pog.Connection,
  hca_id: String,
) -> Result(Member, DatabaseError) {
  let query_result =
    sql.get_member(db_conn, hca_id)
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(RecordNotFound)
  use row <- result.map(row)

  Member(hca_id: row.hca_id, slack_id: row.slack_id, birthdate: row.birthdate)
}

pub fn update_member(
  db_conn: pog.Connection,
  member: Member,
) -> Result(Member, DatabaseError) {
  // TODO support missing birthdates
  let assert Some(birthdate) = member.birthdate
  let query_result =
    sql.update_birthday(db_conn, member.hca_id, birthdate)
    |> result.map_error(QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row =
    rows
    |> list.first
    |> result.replace_error(RecordNotFound)
  use row <- result.map(row)

  Member(hca_id: row.hca_id, slack_id: row.slack_id, birthdate: row.birthdate)
}

pub fn delete_member(
  db_conn: pog.Connection,
  hca_id: String,
) -> Result(Nil, DatabaseError) {
  let query_result =
    sql.delete_birthday(db_conn, hca_id)
    |> result.map_error(QueryError)
  use pog.Returned(count, _) <- result.try(query_result)
  use <- bool.guard(count == 0, Error(RecordNotFound))

  Ok(Nil)
}
