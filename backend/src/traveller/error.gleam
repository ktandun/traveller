import gleam/dynamic.{type DecodeErrors}
import gleam/json.{type DecodeError}
import gleam/pgo.{type QueryError}
import wisp

pub type AppError {
  DatabaseError(QueryError)
  QueryNotReturningSingleResult(String)
  InvalidLogin
  DecodeError(DecodeError)
  JsonDecodeError(DecodeErrors)
  UserAlreadyRegistered
  UserUnauthenticated
  TripDoesNotExist
  InvalidUUIDString(String)
}

pub fn json_codec_decode_error(_) {
  let response =
    [#("title", json.string("JSON_CODEC_DECODE_ERROR"))]
    |> json.object()
    |> json.to_string_builder
    |> wisp.json_response(400)

  response
}

pub fn user_unauthenticated() {
  [#("title", json.string("USER_UNAUTHENTICATED"))]
  |> json.object()
  |> json.to_string_builder
  |> wisp.json_response(401)
}

pub fn invalid_login() {
  [#("title", json.string("INVALID_LOGIN"))]
  |> json.object()
  |> json.to_string_builder
  |> wisp.json_response(400)
}
