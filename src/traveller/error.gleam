import gleam/dynamic.{type DecodeErrors}

pub type AppError {
  JsonDecodeError(DecodeErrors)
  DatabaseError
  UserAlreadyRegistered
  InvalidLogin
}
