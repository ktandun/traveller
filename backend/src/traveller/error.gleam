import gleam/dynamic.{type DecodeErrors}
import gleam/json.{type DecodeError}
import gleam/pgo.{type QueryError}

pub type AppError {
  UserUnauthenticated
  JsonDecodeError(DecodeErrors)
  JsonCodecDecodeError(DecodeError)
  DatabaseError(QueryError)
  UserAlreadyRegistered
  InvalidLogin
  UnableToParseString
}
