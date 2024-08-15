import gleam/dynamic.{type DecodeErrors}

pub type AppError {
  UnknownError
  JsonDecodeError(DecodeErrors)
  DatabaseError
}
