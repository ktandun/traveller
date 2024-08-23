import decode
import gleam/json
import youid/uuid.{type Uuid}

pub type UserId

pub type TripId

pub opaque type Id(entity) {
  Id(Uuid)
}

pub fn id_decoder() {
  decode.into({
    use id <- decode.parameter
    let assert Ok(uid) = uuid.from_string(id)

    uid
  })
  |> decode.field("id", decode.string)
}

pub fn id_encoder(data: Id(a)) {
  let Id(val) = data

  json.object([#("id", json.string(uuid.to_string(val)))])
}

pub fn id_value(id: Id(a)) {
  let Id(value) = id
  value
}

pub fn to_id(id: String) -> Result(Id(a), String) {
  let result = uuid.from_string(id)

  case result {
    Ok(uid) -> Ok(Id(uid))
    Error(_) -> Error("Invalid UUID")
  }
}

pub fn to_id_from_uuid(id: Uuid) -> Id(a) {
  Id(id)
}
