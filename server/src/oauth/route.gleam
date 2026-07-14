import auth/auth
import context
import gleam/bit_array
import gleam/crypto
import gleam/list
import gleam/uri
import member/repository
import oauth/requests as oauth_requests
import wisp

const oauth_state_cookie = "oauth_state"

const oauth_state_lifetime_seconds = 600

pub fn oauth_login(req: wisp.Request, ctx: context.Context) -> wisp.Response {
  let hca_base_url = ctx.config.hca_base_url
  let redirect_uri = uri.percent_encode(ctx.config.hca_redirect_uri)
  let response_type = "code"
  let scope = "openid+slack_id"
  let client_id = ctx.config.hca_client_id
  let state =
    crypto.strong_random_bytes(32)
    |> bit_array.base64_url_encode(False)

  wisp.redirect(
    hca_base_url
    <> "/oauth/authorize?client_id="
    <> client_id
    <> "&redirect_uri="
    <> redirect_uri
    <> "&response_type="
    <> response_type
    <> "&scope="
    <> scope
    <> "&state="
    <> uri.percent_encode(state),
  )
  |> wisp.set_cookie(
    req,
    oauth_state_cookie,
    state,
    wisp.Signed,
    oauth_state_lifetime_seconds,
  )
}

pub fn oauth_callback(
  req: wisp.Request,
  ctx: context.Context,
) -> wisp.Response {
  case callback_code(req) {
    Error(_) -> wisp.response(400)
    Ok(code) -> {
      let assert Ok(token) = oauth_requests.code_token_exchange(code, ctx)
      let assert Ok(hca_payload) =
        oauth_requests.decode_and_verify_token(token.id_token, ctx)

      let db = context.db_conn(ctx)
      let assert Ok(_member) =
        repository.create_member_if_not_exists(
          db,
          hca_payload.sub,
          hca_payload.slack_id,
        )

      let session_token =
        auth.sign_session(
          auth.SessionClaims(
            hca_id: hca_payload.sub,
            slack_id: hca_payload.slack_id,
          ),
          ctx.config.secret_key_base,
        )

      wisp.redirect("/")
      |> wisp.set_cookie(
        req,
        "session",
        session_token,
        wisp.Signed,
        auth.session_lifetime_seconds,
      )
      |> wisp.set_cookie(req, oauth_state_cookie, "", wisp.Signed, 0)
    }
  }
}

@internal
pub fn callback_code(req: wisp.Request) -> Result(String, Nil) {
  let params = wisp.get_query(req)
  case
    list.key_find(params, "code"),
    list.key_find(params, "state"),
    wisp.get_cookie(req, oauth_state_cookie, wisp.Signed)
  {
    Ok(code), Ok(state), Ok(expected_state) -> {
      case
        crypto.secure_compare(
          bit_array.from_string(state),
          bit_array.from_string(expected_state),
        )
      {
        True -> Ok(code)
        False -> Error(Nil)
      }
    }
    _, _, _ -> Error(Nil)
  }
}
