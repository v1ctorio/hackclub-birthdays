import date
import gleam/dynamic/decode.{type Decoder}
import gleam/fetch
import gleam/http.{Get, Patch}
import gleam/http/request
import gleam/http/response.{type Response}
import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/time/calendar
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html.{
  a, button, div, form, h1, h2, input, label, li, p, text, ul,
}
import lustre/event.{on_input, on_submit}
import member.{type Member}

pub type AuthState {
  CheckingSession
  LoggedOut
  LoggedIn(Member)
}

pub type Model {
  Model(
    auth: AuthState,
    members: List(Member),
    members_loading: Bool,
    birthdate_input: String,
    saving: Bool,
    error: Option(String),
  )
}

pub type Msg {
  CurrentUserLoaded(Result(Member, ClientError))
  MembersLoaded(Result(List(Member), ClientError))
  BirthdateChanged(String)
  BirthdaySubmitted
  BirthdaySaved(Result(Member, ClientError))
}

pub type ClientError {
  NetworkError(String)
  InvalidResponse
  StatusError(Int)
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub fn init(_flags) -> #(Model, Effect(Msg)) {
  #(
    Model(
      auth: CheckingSession,
      members: [],
      members_loading: True,
      birthdate_input: "",
      saving: False,
      error: None,
    ),
    effect.batch([load_current_user(), load_members()]),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    CurrentUserLoaded(Ok(current_user)) -> #(
      Model(
        ..model,
        auth: LoggedIn(current_user),
        birthdate_input: member_birthdate(current_user),
      ),
      effect.none(),
    )
    CurrentUserLoaded(Error(StatusError(401))) -> #(
      Model(..model, auth: LoggedOut),
      effect.none(),
    )
    CurrentUserLoaded(Error(error)) -> #(
      Model(..model, auth: LoggedOut, error: Some(error_message(error))),
      effect.none(),
    )
    MembersLoaded(Ok(members)) -> #(
      Model(..model, members:, members_loading: False),
      effect.none(),
    )
    MembersLoaded(Error(error)) -> #(
      Model(..model, members_loading: False, error: Some(error_message(error))),
      effect.none(),
    )
    BirthdateChanged(value) -> #(
      Model(..model, birthdate_input: value),
      effect.none(),
    )
    BirthdaySubmitted -> {
      case model.auth, date.parse_calendar_date(model.birthdate_input) {
        LoggedIn(current_user), Some(birthdate) -> #(
          Model(..model, saving: True, error: None),
          save_birthday(current_user.hca_id, birthdate),
        )
        LoggedIn(_), None -> #(
          Model(..model, error: Some("Choose a valid birthdate.")),
          effect.none(),
        )
        _, _ -> #(model, effect.none())
      }
    }
    BirthdaySaved(Ok(current_user)) -> #(
      Model(
        ..model,
        auth: LoggedIn(current_user),
        birthdate_input: member_birthdate(current_user),
        saving: False,
      ),
      effect.none(),
    )
    BirthdaySaved(Error(error)) -> #(
      Model(..model, saving: False, error: Some(error_message(error))),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  div([], [
    h1([], [text("Hack Club Birthdays")]),
    case model.error {
      Some(error) -> p([], [text("Error: " <> error)])
      None -> element.none()
    },
    auth_view(model),
    h2([], [text("Members")]),
    members_view(model),
  ])
}

fn auth_view(model: Model) -> Element(Msg) {
  case model.auth {
    CheckingSession -> p([], [text("Checking session...")])
    LoggedOut ->
      a([attribute.href("/oauth/login")], [text("Login with Hack Club")])
    LoggedIn(current_user) ->
      div([], [
        h2([], [text("My birthday")]),
        p([], [text("HCA ID: " <> current_user.hca_id)]),
        p([], [text("Slack ID: " <> current_user.slack_id)]),
        form([on_submit(fn(_) { BirthdaySubmitted })], [
          label([attribute.for("birthdate")], [text("Birthdate: ")]),
          input([
            attribute.id("birthdate"),
            attribute.type_("date"),
            attribute.required(True),
            attribute.value(model.birthdate_input),
            on_input(BirthdateChanged),
          ]),
          button(
            [
              attribute.type_("submit"),
              attribute.disabled(model.saving),
            ],
            [
              text(case model.saving {
                True -> "Saving..."
                False -> "Save"
              }),
            ],
          ),
        ]),
      ])
  }
}

fn members_view(model: Model) -> Element(Msg) {
  case model.members_loading, model.members {
    True, _ -> p([], [text("Loading members...")])
    False, [] -> p([], [text("No members yet.")])
    False, members ->
      ul(
        [],
        list.map(members, fn(member) {
          li([], [
            text(member.slack_id <> " — "),
            text(case member.birthdate {
              Some(birthdate) -> date.calendar_date_to_string(birthdate)
              None -> "No birthday set"
            }),
          ])
        }),
      )
  }
}

fn member_birthdate(member: Member) -> String {
  case member.birthdate {
    Some(birthdate) -> date.calendar_date_to_string(birthdate)
    None -> ""
  }
}

fn load_current_user() -> Effect(Msg) {
  effect.from(fn(dispatch) {
    get("/api/me")
    |> promise.map(decode_response(_, member.member_decoder()))
    |> promise.map(CurrentUserLoaded)
    |> promise.tap(dispatch)
    Nil
  })
}

fn load_members() -> Effect(Msg) {
  effect.from(fn(dispatch) {
    get("/api/members")
    |> promise.map(decode_response(_, decode.list(member.member_decoder())))
    |> promise.map(MembersLoaded)
    |> promise.tap(dispatch)
    Nil
  })
}

fn save_birthday(hca_id: String, birthdate: calendar.Date) -> Effect(Msg) {
  let body =
    json.object([#("birthdate", date.calendar_date_to_json(birthdate))])
  effect.from(fn(dispatch) {
    send(Patch, "/api/members/" <> hca_id, body)
    |> promise.map(decode_response(_, member.member_decoder()))
    |> promise.map(BirthdaySaved)
    |> promise.tap(dispatch)
    Nil
  })
}

fn get(path: String) -> Promise(Result(String, ClientError)) {
  send(Get, path, json.null())
}

fn send(
  method: http.Method,
  path: String,
  body: json.Json,
) -> Promise(Result(String, ClientError)) {
  let assert Ok(req) = request.to(absolute_url(path))
  let req =
    req
    |> request.set_method(method)
    |> request.set_body(json.to_string(body))
    |> request.set_header("content-type", "application/json")

  use result <- promise.await(
    fetch.send(req)
    |> promise.await(fn(result) {
      case result {
        Ok(response) -> fetch.read_text_body(response)
        Error(error) -> promise.resolve(Error(error))
      }
    }),
  )

  case result {
    Ok(response) -> {
      let response: Response(String) = response
      case response.status {
        status if status >= 200 && status < 300 ->
          promise.resolve(Ok(response.body))
        status -> promise.resolve(Error(StatusError(status)))
      }
    }
    Error(error) -> promise.resolve(Error(NetworkError(fetch_error(error))))
  }
}

@external(javascript, "./client_ffi.mjs", "absolute_url")
fn absolute_url(path: String) -> String

fn decode_response(
  response: Result(String, ClientError),
  decoder: Decoder(value),
) -> Result(value, ClientError) {
  case response {
    Ok(body) ->
      json.parse(body, decoder) |> result.replace_error(InvalidResponse)
    Error(error) -> Error(error)
  }
}

fn fetch_error(error: fetch.FetchError) -> String {
  case error {
    fetch.NetworkError(message) -> message
    fetch.UnableToReadBody -> "Could not read the response body."
    fetch.InvalidJsonBody -> "The response body was not valid JSON."
  }
}

fn error_message(error: ClientError) -> String {
  case error {
    NetworkError(message) -> "Could not reach the server: " <> message
    InvalidResponse -> "The server returned invalid data."
    StatusError(status) ->
      "The server returned HTTP " <> int.to_string(status) <> "."
  }
}
