import decode
import gleam/pgo
import youid/uuid

pub fn date_decoder() {
  use dynamic <- decode.then(decode.dynamic)
  case pgo.decode_date(dynamic) {
    Ok(date) -> decode.into(date)
    Error(_) -> decode.fail("date")
  }
}

pub fn uuid_decoder() {
  decode.then(decode.bit_array, fn(uuid) {
    case uuid.from_bit_array(uuid) {
      Ok(uuid) -> decode.into(uuid)
      Error(_) -> decode.fail("uuid")
    }
  })
}
