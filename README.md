# Hack Club Birthdays !

[![powered by Gleam](https://img.shields.io/badge/powered_by-gleam-ffaff3?logo=gleam)](https://hex.pm/packages/shared)


## Development

1. fill the .env file
2. `podman compose -f compose-dev.yml up`


## TODO
### Backend
- [ ] log in with HCA
    - [x] extract the slack_id and sub from HCA oidc oauth
    - [ ] store them in jwt
- [ ] authenticate the endpoints to manipulate birthdays
- [x] Set and edit birthdays
- [ ] Allow null inputs to delete birthdays/personal channels
- [ ] allow non-slack oauth
- [ ] add 
