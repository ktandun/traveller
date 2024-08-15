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
  // Create a new database connection for this test
  use db <- database.with_connection()

  // Truncate the database so there is no prexisting data from previous tests
  let context = web.Context(db: db)

  // Run the test with the context
  testcase(context)
}

pub fn login_successful_test() {
  use context <- with_context()

  let json =
    json.object([
      #("email", json.string("test@example.com")),
      #("password", json.string("password")),
    ])
  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(context)

  response.status
  |> should.equal(200)

  response
  |> testing.string_body
  |> birdie.snap(title: "login successful")
}

pub fn login_invalid_json_test() {
  use context <- with_context()

  let json =
    json.object([
      #("email", json.string("test@example.com")),
      #("password", json.bool(True)),
    ])
  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(context)

  response.status
  |> should.equal(400)

  response
  |> testing.string_body
  |> birdie.snap(title: "login invalid")
}
