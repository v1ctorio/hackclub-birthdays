import context
import gleam/list
import wisp

pub fn oauth_login(_req: wisp.Request, ctx: context.Context) -> wisp.Response {
  wisp.redirect(ctx.config.hca_redirect_uri)
}

pub fn oauth_callback(
  req: wisp.Request,
  _ctx: context.Context,
) -> wisp.Response {
  let params = req |> wisp.get_query()
  case params |> list.key_find("code") {
    Error(_) -> wisp.bad_request("Invalid code")
    Ok(code) -> {
      echo code
      wisp.ok()
    }
  }
}
