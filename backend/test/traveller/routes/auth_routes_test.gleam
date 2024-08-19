import gleeunit/should
import shared/auth
import shared/id
import test_utils
import traveller/json_util
import traveller/router
import wisp/testing
import youid/uuid

pub fn signup_successful_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth.SignupRequest(
      email: uuid.to_string(test_utils.gen_uuid()) <> "@example.com",
      password: "password",
    )
    |> auth.signup_request_encoder()

  let response =
    testing.post_json("/signup", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}

pub fn signup_invalid_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth.SignupRequest(email: "test@example.com", password: "password")
    |> auth.signup_request_encoder()

  let response =
    testing.post_json("/signup", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_error(response)
}

pub fn login_successful_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth.LoginRequest(email: "test@example.com", password: "password")
    |> auth.login_request_encoder

  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}

pub fn login_invalid_login_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth.LoginRequest(email: "test@example.com", password: "")
    |> auth.login_request_encoder

  let response =
    testing.post_json("/login", [], json)
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}

pub fn login_invalid_json_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.post("/login", [], "{hey}")
    |> test_utils.set_json_header
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}
