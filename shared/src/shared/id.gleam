import gleam/json
import gleam/string
import shared/custom_decoders
import toy

pub type UserId

pub type TripId

pub type TripCompanionId

pub type TripPlaceId

pub opaque type Id(entity) {
  Id(String)
}

pub fn id_decoder() {
  use id <- toy.field("id", custom_decoders.uuid_decoder("id"))
  toy.decoded(Id(id))
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
  Id(id |> string.lowercase)
}
