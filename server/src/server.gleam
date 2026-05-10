import config
import context
import database
import gleam/erlang/process
import mist
import router
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()

  let config = config.load()
  let db_pool_name = database.start(config)
  let context = context.Context(config:, db_pool_name:)

  let assert Ok(_) =
    router.handle_request(_, context)
    |> wisp_mist.handler(config.secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
