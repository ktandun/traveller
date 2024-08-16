import gleam_community/codec

pub type LoginRequest {
  LoginRequest(email: String, password: String)
}

pub type SignupRequest {
  SignupRequest(email: String, password: String)
}

pub fn login_request_codec() {
  codec.custom({
    use login_request_codec <- codec.variant2(
      "LoginRequest",
      LoginRequest,
      codec.string(),
      codec.string(),
    )

    codec.make_custom(fn(value) {
      case value {
        LoginRequest(email, password) -> login_request_codec(email, password)
      }
    })
  })
}

pub fn signup_request_codec() {
  codec.custom({
    use signup_request_codec <- codec.variant2(
      "SignupRequest",
      SignupRequest,
      codec.string(),
      codec.string(),
    )

    codec.make_custom(fn(value) {
      case value {
        SignupRequest(email, password) -> signup_request_codec(email, password)
      }
    })
  })
}
