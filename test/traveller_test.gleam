import birdie
import gleam/json
import gleeunit
import gleeunit/should
import traveller/database
import traveller/router
import traveller/web
import wisp
import wisp/testing

pub fn main() {
  gleeunit.main()
}

fn with_context(testcase: fn(web.Context) -> t) -> t {
  use db <- database.with_connection()

  let context = web.Context(db: db)

  testcase(context)
}

pub fn login_successful_test() {
  use ctx <- with_context()

  let json =
    json.object([
      #("email", json.string("test@example.com")),
      #("password", json.string("password")),
    ])
  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  response
  |> testing.string_body
  |> birdie.snap(title: "login successful")

  response.status
  |> should.equal(200)
}

pub fn login_invalid_json_test() {
  use ctx <- with_context()

  let json =
    json.object([
      #("email", json.string("test@example.com")),
      #("password", json.bool(True)),
    ])
  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  response
  |> testing.string_body
  |> birdie.snap(title: "login invalid")

  response.status
  |> should.equal(400)
}

pub fn admin_unauthorised_test() {
  use ctx <- with_context()

  let response =
    testing.get("/trips", [])
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn admin_authorised_test() {
  use ctx <- with_context()

  let response =
    testing.get("/trips", [])
    |> testing.set_cookie(
      "traveller.auth",
      "00000000-0000-0000-0000-000000000001",
      wisp.Signed,
    )
    |> router.handle_request(ctx)

  response.status
  |> should.equal(200)
}

pub fn get_user_trips_test() {
  use ctx <- with_context()

  let response =
    testing.get("/trips", [])
    |> testing.set_cookie(
      "traveller.auth",
      "00000000-0000-0000-0000-000000000001",
      wisp.Signed,
    )
    |> router.handle_request(ctx)

  response
  |> testing.string_body
  |> birdie.snap(title: "get user trips test")
}
