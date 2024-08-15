import birdie
import gleam/json
import gleeunit
import gleeunit/should
import traveller/database
import traveller/router
import traveller/web
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
