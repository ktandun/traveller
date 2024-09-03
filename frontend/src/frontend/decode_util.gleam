import gleam/dynamic.{type DecodeError, DecodeError}
import gleam/list
import gleam/result
import toy.{type ToyError}

pub fn map_toy_error_to_decode_errors(
  res: Result(a, List(ToyError)),
) -> Result(a, List(DecodeError)) {
  res
  |> result.map_error(fn(e) {
    e
    |> list.map(fn(val) { DecodeError(expected: "", found: "", path: val.path) })
  })
}
