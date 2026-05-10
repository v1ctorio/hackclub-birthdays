import context.{type Context}
import wisp.{type Request, type Response}

pub fn list_members(_ctx: Context) -> Response {
  wisp.ok()
  |> wisp.json_body("[]")
}

pub fn create_member(_req: Request, _ctx: Context) -> Response {
  wisp.created()
  |> wisp.json_body("{}")
}

pub fn get_member(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{}")
}

pub fn update_member(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{}")
}

pub fn delete_member(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.no_content()
}
