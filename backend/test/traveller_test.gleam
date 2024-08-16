import birdie
import gleam_community/codec
import gleeunit
import gleeunit/should
import shared/auth
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
    auth.LoginRequest(email: "test@example.com", password: "password")
    |> codec.encode_json(auth.login_request_codec())

  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  response
  |> testing.string_body
  |> birdie.snap(title: "login successful")

  response.status
  |> should.equal(200)
}

pub fn login_invalid_login_test() {
  use ctx <- with_context()

  let json =
    auth.LoginRequest(email: "test@example.com", password: "")
    |> codec.encode_json(auth.login_request_codec())

  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  response
  |> testing.string_body
  |> birdie.snap(title: "login invalid login")

  response.status
  |> should.equal(400)
}

pub fn login_invalid_json_test() {
  use ctx <- with_context()

  let response =
    testing.post("/login", [], "{hey}")
    |> testing.set_header("content-type", "application/json")
    |> router.handle_request(ctx)

  response
  |> testing.string_body
  |> birdie.snap(title: "login invalid json")

  response.status
  |> should.equal(400)
}

pub fn trips_unauthorised_test() {
  use ctx <- with_context()

  let response =
    testing.get("/trips", [])
    |> router.handle_request(ctx)

  response.status
  |> should.equal(401)
}

pub fn trips_authorised_test() {
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
