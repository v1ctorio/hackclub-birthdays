import context
import gleam/http.{Delete, Get, Patch, Post}
import member/route as member_routes
import oauth/route as oauth_routes
import web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: context.Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["api", "members", ..rest] -> handle_tasks(rest, req, ctx)
    ["oauth", ..rest] -> handle_oauth(rest, req, ctx)
    _ -> wisp.not_found()
  }
}

fn handle_tasks(
  segments: List(String),
  req: Request,
  ctx: context.Context,
) -> Response {
  case segments, req.method {
    [], Get -> member_routes.list_members(ctx)
    [], Post -> member_routes.create_member(req, ctx)
    [], _ -> wisp.method_not_allowed([Get, Post])

    [id], Get -> member_routes.get_member(req, ctx, id)
    [id], Patch -> member_routes.update_member(req, ctx, id)
    [id], Delete -> member_routes.delete_member(req, ctx, id)
    [_], _ -> wisp.method_not_allowed([Get, Patch, Delete])
    _, _ -> wisp.not_found()
  }
}

fn handle_oauth(
  segments: List(String),
  req: Request,
  ctx: context.Context,
) -> Response {
  case segments, req.method {
    ["login"], Get -> oauth_routes.oauth_login(req, ctx)
    ["callback"], Get -> oauth_routes.oauth_callback(req, ctx)
    _, _ -> wisp.not_found()
  }
}
