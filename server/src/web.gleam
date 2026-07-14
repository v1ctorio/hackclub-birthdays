import auth/auth
import context.{type Context}
import error.{type DatabaseError, RecordNotFound}
import gleam/dynamic/decode.{type Decoder}
import wisp.{type Request, type Response}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(Request) -> Response,
) -> wisp.Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  handle_request(req)
}

pub fn decode_body(
  json: decode.Dynamic,
  decoder: Decoder(a),
  next: fn(a) -> Response,
) -> Response {
  case decode.run(json, decoder) {
    Ok(value) -> next(value)
    Error(_) -> wisp.unprocessable_content()
  }
}

pub fn db_execute(
  result: Result(a, DatabaseError),
  next: fn(a) -> Response,
) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(RecordNotFound) -> wisp.not_found()
    Error(_) -> wisp.internal_server_error()
  }
}

pub fn auth_mw(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request, auth.SessionClaims) -> wisp.Response,
) -> wisp.Response {
  case wisp.get_cookie(req, "session", wisp.Signed) {
    Ok(token) -> {
      case auth.verify_session(token, ctx.config.secret_key_base) {
        Ok(claims) -> handle_request(req, claims)
        Error(_) -> wisp.response(401)
      }
    }
    Error(_) -> wisp.response(401)
  }
}
