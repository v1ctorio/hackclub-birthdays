import context
import gleam/list
import gleam/uri
import wisp

pub fn oauth_login(_req: wisp.Request, ctx: context.Context) -> wisp.Response {
  let redirect_uri = uri.percent_encode(ctx.config.hca_redirect_uri)
  let response_type = "code"
  let scope = "openid"
  let client_id = ctx.config.hca_client_id

  wisp.redirect(
    echo "https://auth.hackclub.com/oauth/authorize?client_id="
      <> client_id
      <> "&redirect_uri="
      <> redirect_uri
      <> "&response_type="
      <> response_type
      <> "&scope="
      <> scope,
  )
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
