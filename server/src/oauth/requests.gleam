import context
import gjwt
import gjwt/key as gjwt_key
import gleam/bool
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/json
import gleam/result
import oauth/types.{type TokenRes, token_res_from_json}
import qol_gleam/qol_result

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
pub fn validate_token(token: String, ctx: context.Context) -> Bool {
  let assert Ok(base_req) =
    request.to(ctx.config.hca_base_url <> "/oauth/discovery/keys")

  let req = base_req |> request.set_method(http.Get)
  use resp <- qol_result.guard(httpc.send(req), False)
  use <- bool.guard(when: resp.status != 200, return: False)
  use key <- qol_result.guard(types.key_from_json(resp.body), False)
  echo gjwt.verify(token, gjwt_key.from_string(key.e, key.alg))
}
