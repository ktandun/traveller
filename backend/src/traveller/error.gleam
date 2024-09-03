import gleam/dynamic.{type DecodeErrors}
import gleam/json
import gleam/pgo.{type QueryError}
import toy.{type ToyError}
import wisp

pub type AppError {
  DatabaseError(QueryError)
  QueryNotReturningSingleResult(String)
  InvalidLogin
  BodyNotJsonError
  DecodeError(List(ToyError))
  JsonDecodeError(DecodeErrors)
  UserAlreadyRegistered
  UserUnauthenticated
  TripDoesNotExist
  InvalidDateSpecified
  InvalidDestinationSpecified
  InvalidUUIDString(String)
}

pub fn json_codec_decode_error(e) {
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
