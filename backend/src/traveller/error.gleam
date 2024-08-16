import gleam/dynamic.{type DecodeErrors}
import gleam/pgo.{type QueryError}

pub type AppError {
  UserUnauthenticated
  JsonDecodeError(DecodeErrors)
  DatabaseError(QueryError)
  UserAlreadyRegistered
  InvalidLogin
  UnableToParseString
}
