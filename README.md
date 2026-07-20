# Hack Club Birthdays !

[![powered by Gleam](https://img.shields.io/badge/powered_by-gleam-ffaff3?logo=gleam)](https://hex.pm/packages/shared)

Birthdays website built using the gleam functional programming language. The most tedious part was the backend. There is a simple non feature complete frontend that I ought to improve.

## Development

1. fill the `.env` (based on the `.env.example`)

- Database 
    - `podman compose -f compose-dev.yml up` to start it, or start a local postgres based on the config in there
- start the backend
    - `cd server`; `gleam check`
    - `set -a && source ../.env && set +a` to load the env vars
    - `gleam run`
- start the frontend (separate component)
    - `cd frontend`; `gleam check`
    - `gleam run -m lustre/dev start`

The app will be ready in `localhost:1234`
## TODO
### Backend
- [x] log in with HCA
    - [x] extract the slack_id and sub from HCA oidc oauth
    - [x] store them in jwt
- [ ] authenticate the endpoints to manipulate birthdays
- [x] Set and edit birthdays
- [ ] Allow null inputs to delete birthdays/personal channels
- [ ] allow non-slack oauth
- [ ] proper beautiful frontend 