import gleam/result
import gleam_community/codec.{type Codec}
import traveller/error.{type AppError}

pub fn try_decode(json: String, decoder: Codec(a)) -> Result(a, AppError) {
  codec.decode_string(json, decoder)
  |> result.map_error(fn(e) { error.JsonCodecDecodeError(e) })
}
