import context
import gleam/bool
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result
import gleam/time/duration
import oauth/types.{type TokenRes, token_res_from_json}
import qol_gleam/qol_result
import ywt
import ywt/claim

pub fn code_token_exchange(
  code: String,
  ctx: context.Context,
) -> Result(TokenRes, String) {
  let client_id = ctx.config.hca_client_id
  let client_secret = ctx.config.hca_client_secret
  let redirect_uri = ctx.config.hca_redirect_uri

  let assert Ok(base_req) =
    request.to(ctx.config.hca_base_url <> "/oauth/token")

  let req =
    base_req
    |> request.set_method(http.Post)
    |> request.set_header("Content-Type", "application/x-www-form-urlencoded")
    |> request.set_body(
      "grant_type=authorization_code"
      <> "&code="
      <> code
      <> "&redirect_uri="
      <> redirect_uri
      <> "&client_id="
      <> client_id
      <> "&client_secret="
      <> client_secret,
    )

  use resp <- result.try(httpc.send(req) |> result.map_error(fn(_e) { "test" }))

  echo #(resp, resp.body)
  use <- bool.guard(when: resp.status != 200, return: {
    Error("Non Ok response from oauth provider")
  })

  use token_res <- result.try(
    token_res_from_json(resp.body)
    |> result.map_error(fn(_e) { "Failed to decode token response" }),
  )

  Ok(token_res)
}

// TODO store in cache HCA keys
pub fn decode_and_verify_token(
  token: String,
  ctx: context.Context,
) -> Result(types.HCAJWTPayload, TokenDecodeError) {
  let assert Ok(base_req) =
    request.to(ctx.config.hca_base_url <> "/oauth/discovery/keys")
  let req =
    base_req
    |> request.set_method(http.Get)
  use resp <- result.try(
    httpc.send(req) |> result.map_error(fn(_) { HCAKeyFetchError }),
  )
  use <- bool.guard(when: resp.status != 200, return: {
    Error(HCAKeyFetchError)
  })

  use ywt_ver_key <- result.try(
    types.stringjwk_to_ywt_verify_key(resp.body)
    |> result.map_error(fn(e) { HCAKeyDecodeError(e) }),
  )
  let claims = [
    claim.expires_at(max_age: duration.hours(1), leeway: duration.minutes(5)),
    claim.audience(ctx.config.hca_client_id, []),
  ]

  let decoder = types.get_hca_payloadd_decoder()
  ywt.decode(jwt: token, using: decoder, keys: [ywt_ver_key], claims:)
  |> result.map_error(fn(e) { HCATokenDecodeError(e) })
}

pub type TokenDecodeError {
  HCAKeyFetchError
  HCAKeyDecodeError(json.DecodeError)
  // probably means invalid signature
  HCATokenDecodeError(ywt.ParseError)
}
