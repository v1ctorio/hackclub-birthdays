import context.{type Context}
import gleam/bool
import gleam/json
import member
import member/repository
import web
import wisp.{type Request, type Response}

//TODO middleware AUTHENTICATION for all requests + check id for create, update and delete

pub fn list_members(ctx: Context) -> Response {
  let db = context.db_conn(ctx)
  use members <- web.db_execute(repository.all_members(db))
  members
  |> json.array(member.member_to_json)
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

pub fn create_member(req: Request, ctx: Context) -> Response {
  let db = context.db_conn(ctx)
  use json <- wisp.require_json(req)
  use member_input <- web.decode_body(json, member.member_input_decoder())

  //TODO EXTRACT HCA_ID AND SLACK_ID FROM REQUEST HEADERS (auth)
  let hca_id = "hca_id"
  let slack_id = "slack_id"
  use member <- web.db_execute(repository.create_member(
    db,
    member_input,
    hca_id,
    slack_id,
  ))

  member
  |> member.member_to_json
  |> json.to_string
  |> wisp.json_body(wisp.created(), _)
}

pub fn get_member(_req: Request, ctx: Context, hca_id: String) -> Response {
  let db = context.db_conn(ctx)
  use member <- web.db_execute(repository.get_member(db, hca_id))

  member
  |> member.member_to_json
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

pub fn update_member(req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use json <- wisp.require_json(req)
  use member_input <- web.decode_body(json, member.member_input_decoder())
  // TODO Same, extract hca_id and slack_id from auth
  let hca_id = "hca_id"
  // check if hca_id equals _id and return 403 if not
  // It took me TOO long to realize how to do this gng
  use <- bool.guard(when: hca_id != id, return: { wisp.internal_server_error() })
  //TODO return forbidden code why does wisp not provide a method for this???

  let member = member.to_member(member_input, "hca_id", "slack_id")
  use member <- web.db_execute(repository.update_member(db, member))

  member
  |> member.member_to_json
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

pub fn delete_member(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.no_content()
}
