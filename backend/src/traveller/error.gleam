import gleam/int
import gleam/io
import gleam/json
import gleam/pgo.{
  ConnectionUnavailable, ConstraintViolated, PostgresqlError,
  UnexpectedArgumentCount, UnexpectedArgumentType, UnexpectedResultType,
}
import toy.{type ToyError}
import wisp

pub type AppError {
  DatabaseError(pgo.QueryError)
  QueryNotReturningSingleResult(String)
  BodyNotJsonError
  TransactionError(pgo.TransactionError)
  DecodeError(List(ToyError))
  UserUnauthenticated
  ValidationFailed(String)
  VerificationFailed(String)
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

pub fn transaction_error(e: pgo.TransactionError) {
  case e {
    pgo.TransactionQueryError(query_error) -> log_query_error(query_error)
    pgo.TransactionRolledBack(err) -> wisp.log_error(err)
  }

  [#("title", json.string("TRANSACTION_ERROR"))]
  |> json.object()
  |> json.to_string_builder
  |> wisp.json_response(400)
}

pub fn log_query_error(query_error: pgo.QueryError) {
  case query_error {
    ConstraintViolated(message, constraint, detail) -> {
      wisp.log_error(
        "ConstraintViolated "
        <> message
        <> " constraint: "
        <> constraint
        <> " detail: "
        <> detail,
      )
    }
    PostgresqlError(code, name, message) -> {
      wisp.log_error(
        "postgresqlerror "
        <> code
        <> " name: "
        <> name
        <> " message: "
        <> message,
      )
    }
    UnexpectedArgumentCount(expected, got) -> {
      wisp.log_error(
        "UnexpectedArgumentCount"
        <> " expected: "
        <> int.to_string(expected)
        <> " got: "
        <> int.to_string(got),
      )
    }
    UnexpectedArgumentType(expected, got) -> {
      wisp.log_error(
        "UnexpectedArgumentType" <> " expected: " <> expected <> " got: " <> got,
      )
    }
    UnexpectedResultType(e) -> {
      io.debug(e)
      wisp.log_error("UnexpectedResultType")
    }
    ConnectionUnavailable -> {
      wisp.log_error("ConnectionUnavailable")
    }
  }
}
