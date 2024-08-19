import decode
import youid/uuid

pub fn uuid_decoder() {
  decode.then(decode.bit_array, fn(uuid) {
    case uuid.from_bit_array(uuid) {
      Ok(uuid) -> decode.into(uuid)
      Error(_) -> decode.fail("uuid")
    }
  })
}

pub fn uuid_decoder_from_string() {
  decode.then(decode.string, fn(uuid) {
    case uuid.from_string(uuid) {
      Ok(uuid) -> decode.into(uuid)
      Error(_) -> decode.fail("uuid")
    }
  })
}
