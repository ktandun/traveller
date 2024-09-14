import gleam/json
import toy

//

pub type LoginRequest {
  LoginRequest(email: String, password: String)
}

pub fn default_login_request() {
  LoginRequest(email: "", password: "")
}

pub fn login_request_decoder() {
  use email <- toy.field("email", toy.string |> toy.string_email)
  use password <- toy.field("password", toy.string |> toy.string_min(8))

  toy.decoded(LoginRequest(email:, password:))
}

pub fn login_request_encoder(data: LoginRequest) {
  json.object([
    #("email", json.string(data.email)),
    #("password", json.string(data.password)),
  ])
}

//

pub type SignupRequest {
  SignupRequest(email: String, password: String)
}

pub fn signup_request_decoder() {
  use email <- toy.field("email", toy.string |> toy.string_email)
  use password <- toy.field("password", toy.string |> toy.string_min(8))

  toy.decoded(SignupRequest(email:, password:))
}

pub fn signup_request_encoder(data: SignupRequest) {
  json.object([
    #("email", json.string(data.email)),
    #("password", json.string(data.password)),
  ])
}
