import decode
import gleam/json

//

pub type LoginRequest {
  LoginRequest(email: String, password: String)
}

pub fn default_login_request() {
  LoginRequest(email: "", password: "")
}

pub fn login_request_decoder() {
  decode.into({
    use email <- decode.parameter
    use password <- decode.parameter
    LoginRequest(email:, password:)
  })
  |> decode.field("email", decode.string)
  |> decode.field("password", decode.string)
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
  decode.into({
    use email <- decode.parameter
    use password <- decode.parameter
    SignupRequest(email:, password:)
  })
  |> decode.field("email", decode.string)
  |> decode.field("password", decode.string)
}

pub fn signup_request_encoder(data: SignupRequest) {
  json.object([
    #("email", json.string(data.email)),
    #("password", json.string(data.password)),
  ])
}
