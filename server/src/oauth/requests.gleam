import context
import gleam/bool
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/json
import gleam/result

pub type TokenRes {
  TokenRes(
    access_token: String,
    expires_in: Int,
    refresh_token: String,
    token_type: String,
    id_token: String,
  )
}

pub fn token_res_from_json(
  json_string: String,
) -> Result(TokenRes, json.DecodeError) {
  let tokens_decoder = {
    use access_token <- decode.field("access_token", decode.string)
    use token_type <- decode.field("token_type", decode.string)
    use expires_in <- decode.field("expires_in", decode.int)
    use refresh_token <- decode.field("refresh_token", decode.string)
    use id_token <- decode.field("id_token", decode.string)
    decode.success(TokenRes(
      access_token:,
      expires_in:,
      refresh_token:,
      token_type:,
      id_token:,
    ))
  }
  json.parse(json_string, using: tokens_decoder)
}

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
