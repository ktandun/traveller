import gleam/dynamic
import gleam/json
import gleam/result
import toy
import traveller/error.{type AppError}

pub fn try_decode(
  json_str: String,
  decoder: toy.Decoder(a),
) -> Result(a, AppError) {
  case json.decode(json_str, dynamic.dynamic) {
    Ok(data) ->
      data
      |> toy.decode(decoder)
      |> result.map_error(fn(e) { error.DecodeError(e) })
    Error(_) -> Error(error.BodyNotJsonError)
  }
}
