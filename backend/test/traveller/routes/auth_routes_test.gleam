import gleam/http/response
import gleam/list
import gleeunit/should
import shared/auth_models
import shared/id
import test_utils
import traveller/json_util
import traveller/router
import wisp/testing
import youid/uuid

pub fn signup_successful_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth_models.SignupRequest(
      email: uuid.to_string(test_utils.gen_uuid()) <> "@example.com",
      password: "password",
    )
    |> auth_models.signup_request_encoder()

  let response =
    testing.post_json("/api/signup", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_ok(response)
}

pub fn signup_invalid_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth_models.SignupRequest(email: "test@example.com", password: "password")
    |> auth_models.signup_request_encoder()

  let response =
    testing.post_json("/api/signup", [], json)
    |> router.handle_request(ctx)

  let response =
    json_util.try_decode(testing.string_body(response), id.id_decoder())

  should.be_error(response)
}

pub fn login_successful_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth_models.LoginRequest(email: "test@example.com", password: "password")
    |> auth_models.login_request_encoder

  let response =
    testing.post_json("/api/login", [], json)
    |> router.handle_request(ctx)

  should.equal(200, response.status)

  let cookies = response.get_cookies(response)

  should.be_false(list.is_empty(cookies))

  test_utils.reset_testing_user_session_token()
}

pub fn login_invalid_login_test() {
  use ctx <- test_utils.with_context()

  let json =
    auth_models.LoginRequest(email: "test@example.com", password: "")
    |> auth_models.login_request_encoder

  let response =
    testing.post_json("/api/login", [], json)
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}

pub fn login_invalid_json_test() {
  use ctx <- test_utils.with_context()

  let response =
    testing.post("/api/login", [], "{hey}")
    |> test_utils.set_json_header
    |> router.handle_request(ctx)

  response.status
  |> should.equal(400)
}
