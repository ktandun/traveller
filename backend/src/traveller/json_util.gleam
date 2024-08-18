import decode.{type Decoder}
import gleam/json
import gleam/result
import traveller/error.{type AppError}

pub fn try_decode(json_str: String, decoder: Decoder(a)) -> Result(a, AppError) {
  json_str
  |> json.decode(fn(j) { decoder |> decode.from(j) })
  |> result.map_error(fn(e) { error.JsonCodecDecodeError(e) })
}
