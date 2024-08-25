import decode
import gleam/json

pub type UserId

pub type TripId

pub type TripPlaceId

pub opaque type Id(entity) {
  Id(String)
}

pub fn id_decoder() {
  decode.into({
    use id <- decode.parameter
    Id(id)
  })
  |> decode.field("id", decode.string)
}

pub fn id_encoder(data: Id(a)) {
  let Id(val) = data

  json.object([#("id", json.string(val))])
}

pub fn id_value(id: Id(a)) {
  let Id(value) = id
  value
}

pub fn to_id(id: String) -> Id(a) {
  Id(id)
}
