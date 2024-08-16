import gleam_community/codec

pub type UserId

pub type TripId

pub opaque type Id(entity) {
  Id(String)
}

pub fn id_codec() {
  codec.custom({
    use id_codec <- codec.variant1("Id", Id, codec.string())

    codec.make_custom(fn(value) {
      case value {
        Id(id) -> id_codec(id)
      }
    })
  })
}

pub fn id_value(id: Id(a)) {
  let Id(value) = id
  value
}

pub fn to_user_id(id: String) -> Id(UserId) {
  Id(id)
}

pub fn to_trip_id(id: String) -> Id(TripId) {
  Id(id)
}
