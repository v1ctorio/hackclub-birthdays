import gleam/bit_array
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import ywt/verify_key

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

pub type KeysDiscoveryRes {
  KeysDiscoveryRes(keys: List(Jwk))
}

pub type Jwk {
  Jwk(kty: String, n: String, e: String, kid: String, use_: String, alg: String)
}

pub fn keys_from_json(
  json_string: String,
) -> Result(KeysDiscoveryRes, json.DecodeError) {
  let jwk_decoder = {
    use kty <- decode.field("kty", decode.string)
    use n <- decode.field("n", decode.string)
    use e <- decode.field("e", decode.string)
    use kid <- decode.field("kid", decode.string)
    use use_ <- decode.field("use", decode.string)
    use alg <- decode.field("alg", decode.string)
    decode.success(Jwk(kty:, n:, e:, kid:, use_:, alg:))
  }

  let keys_decoder = {
    use keys <- decode.field("keys", decode.list(of: jwk_decoder))
    decode.success(KeysDiscoveryRes(keys: keys))
  }

  json.parse(json_string, using: keys_decoder)
}

// I probably should get better names for these
pub fn key_from_json(json_string: String) -> Result(Jwk, json.DecodeError) {
  use keys_res <- result.try(keys_from_json(json_string))
  case keys_res.keys {
    [] -> Error(json.UnexpectedSequence("No keys found in discovery response"))
    [key, ..] -> Ok(key)
  }
}

pub fn stringjwk_to_ywt_verify_key(
  response: String,
) -> Result(verify_key.VerifyKey, json.DecodeError) {
  // this (converting back to json) is like extremely inefficient but i really don't know how else to do this right now
  use jwk <- result.try(key_from_json(response))
  // using it just in case my horrible code could get optmized
  echo #("twying to parse ", jwk)
  let jwk = jwk_to_json(jwk)
  json.parse(jwk, verify_key.decoder())
}

// This is so silly and i hate it
fn jwk_to_json(jwk: Jwk) -> String {
  json.object([
    #("kty", json.string(jwk.kty)),
    #("n", json.string(jwk.n)),
    #("e", json.string(jwk.e)),
    #("kid", json.string(jwk.kid)),
    #("use", json.string(jwk.use_)),
    #("alg", json.string(jwk.alg)),
  ])
  |> json.to_string()
}

pub type HCAJWTPayload {
  HCAJWTPayload(iss: String, sub: String, slack_id: String)
}

pub fn get_hca_payloadd_decoder() -> decode.Decoder(HCAJWTPayload) {
  use iss <- decode.field("iss", decode.string)
  use sub <- decode.field("sub", decode.string)
  use slack_id <- decode.field("slack_id", decode.string)
  decode.success(HCAJWTPayload(iss:, sub:, slack_id:))
}
