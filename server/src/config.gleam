import envoy
import gleam/int
import gleam/result
import mist

pub type Config {
  Config(
    db_host: String,
    db_port: Int,
    db_name: String,
    db_user: String,
    db_password: String,
    secret_key_base: String,
    server_host: String,
    server_port: Int,
    hca_client_id: String,
    hca_client_secret: String,
    hca_redirect_uri: String,
    hca_base_url: String,
  )
}

pub fn load() -> Config {
  let assert Ok(db_host) = envoy.get("PGHOST")
  let assert Ok(db_port) = envoy.get("PGPORT") |> result.try(int.parse)
  let assert Ok(db_name) = envoy.get("PGDATABASE")
  let assert Ok(db_user) = envoy.get("PGUSER")
  let assert Ok(db_password) = envoy.get("PGPASSWORD")
  let assert Ok(secret_key_base) = envoy.get("SECRET_KEY_BASE")
  let assert Ok(server_host) = envoy.get("SERVER_HOST")
  let assert Ok(server_port) = envoy.get("SERVER_PORT") |> result.try(int.parse)
  let assert Ok(hca_client_id) = envoy.get("HCA_CLIENT_ID")
  let assert Ok(hca_client_secret) = envoy.get("HCA_CLIENT_SECRET")
  let assert Ok(hca_redirect_uri) = envoy.get("HCA_REDIRECT_URI")
  let assert Ok(hca_base_url) = envoy.get("HCA_BASE_URL")

  Config(
    secret_key_base:,
    server_host:,
    server_port:,
    db_host:,
    db_port:,
    db_name:,
    db_user:,
    db_password:,
    hca_client_id:,
    hca_client_secret:,
    hca_redirect_uri:,
    hca_base_url:,
  )
}
