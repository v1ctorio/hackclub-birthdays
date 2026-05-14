import context
import gleam/list
import gleam/uri
import oauth/requests as oauth_requests
import qol_gleam/qol_result
import wisp

pub fn oauth_login(_req: wisp.Request, ctx: context.Context) -> wisp.Response {
  let hca_base_url = ctx.config.hca_base_url
  let redirect_uri = uri.percent_encode(ctx.config.hca_redirect_uri)
  let response_type = "code"
  let scope = "openid+slack_id"
  let client_id = ctx.config.hca_client_id

  wisp.redirect(
    echo hca_base_url
      <> "/oauth/authorize?client_id="
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
  ctx: context.Context,
) -> wisp.Response {
  let params = req |> wisp.get_query()
  case params |> list.key_find("code") {
    Error(_) -> wisp.bad_request("Invalid code")
    Ok(code) -> {
      echo code
      let assert Ok(token) = oauth_requests.code_token_exchange(code, ctx)
      let decoded =
        echo oauth_requests.decode_and_verify_token(token.id_token, ctx)
      use something <- qol_result.guard(decoded, wisp.content_too_large())
      echo something

      wisp.ok()
    }
  }
}
