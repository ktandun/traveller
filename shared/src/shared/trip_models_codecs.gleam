import gleam/json
import shared/custom_decoders
import shared/trip_models
import toy

//

pub fn place_activity_decoder() {
  use place_activity_id <- toy.field("place_activity_id", toy.string)
  use name <- toy.field("name", toy.string)
  use information_url <- toy.field(
    "information_url",
    toy.string |> toy.nullable,
  )
  use start_time <- toy.field("start_time", toy.string |> toy.nullable)
  use end_time <- toy.field("end_time", toy.string |> toy.nullable)
  use entry_fee <- toy.field(
    "entry_fee",
    custom_decoders.number |> toy.nullable,
  )

  toy.decoded(trip_models.PlaceActivity(
    place_activity_id:,
    name:,
    information_url:,
    start_time:,
    end_time:,
    entry_fee:,
  ))
}

pub fn place_activity_encoder(data: trip_models.PlaceActivity) {
  json.object([
    #("place_activity_id", json.string(data.place_activity_id)),
    #("name", json.string(data.name)),
    #("information_url", json.nullable(data.information_url, json.string)),
    #("start_time", json.nullable(data.start_time, json.string)),
    #("end_time", json.nullable(data.end_time, json.string)),
    #("entry_fee", json.nullable(data.entry_fee, json.float)),
  ])
}

pub fn place_activities_decoder() {
  use trip_id <- toy.field("trip_id", toy.string)
  use trip_place_id <- toy.field("trip_place_id", toy.string)
  use place_name <- toy.field("place_name", toy.string)
  use place_activities <- toy.field(
    "place_activities",
    toy.list(place_activity_decoder()),
  )

  toy.decoded(trip_models.PlaceActivities(
    trip_id:,
    trip_place_id:,
    place_name:,
    place_activities:,
  ))
}

pub fn place_activities_encoder(data: trip_models.PlaceActivities) {
  json.object([
    #("trip_id", json.string(data.trip_id)),
    #("trip_place_id", json.string(data.trip_place_id)),
    #("place_name", json.string(data.place_name)),
    #(
      "place_activities",
      json.array(from: data.place_activities, of: place_activity_encoder),
    ),
  ])
}

//

pub fn place_accomodation_decoder() {
  use place_accomodation_id <- toy.field("place_accomodation_id", toy.string)
  use place_name <- toy.field("place_name", toy.string)
  use accomodation_name <- toy.field("accomodation_name", toy.string)
  use information_url <- toy.field(
    "information_url",
    toy.string |> toy.nullable,
  )
  use accomodation_fee <- toy.field(
    "accomodation_fee",
    custom_decoders.number |> toy.nullable,
  )
  use paid <- toy.field("paid", toy.bool)

  toy.decoded(trip_models.PlaceAccomodation(
    place_accomodation_id:,
    place_name:,
    accomodation_name:,
    information_url:,
    accomodation_fee:,
    paid:,
  ))
}

pub fn place_accomodation_encoder(data: trip_models.PlaceAccomodation) {
  json.object([
    #("place_accomodation_id", json.string(data.place_accomodation_id)),
    #("place_name", json.string(data.place_name)),
    #("accomodation_name", json.string(data.accomodation_name)),
    #("information_url", json.nullable(data.information_url, json.string)),
    #("accomodation_fee", json.nullable(data.accomodation_fee, json.float)),
    #("paid", json.bool(data.paid)),
  ])
}

//

pub fn trip_place_culinaries_encoder(data: trip_models.PlaceCulinaries) {
  json.object([
    #("trip_id", json.string(data.trip_id)),
    #("trip_place_id", json.string(data.trip_place_id)),
    #("place_name", json.string(data.place_name)),
    #(
      "place_culinaries",
      json.array(data.place_culinaries, of: trip_place_culinary_encoder),
    ),
  ])
}

pub fn trip_place_culinary_encoder(data: trip_models.PlaceCulinary) {
  json.object([
    #("place_culinary_id", json.string(data.place_culinary_id)),
    #("name", json.string(data.name)),
    #("open_time", json.nullable(data.open_time, json.string)),
    #("close_time", json.nullable(data.close_time, json.string)),
    #("information_url", json.nullable(data.information_url, json.string)),
  ])
}

pub fn trip_place_culinaries_decoder() {
  use trip_id <- toy.field("trip_id", toy.string)
  use trip_place_id <- toy.field("trip_place_id", toy.string)
  use place_name <- toy.field("place_name", toy.string)
  use place_culinaries <- toy.field(
    "place_culinaries",
    toy.list(trip_place_culinary_decoder()),
  )

  toy.decoded(trip_models.PlaceCulinaries(
    trip_id:,
    trip_place_id:,
    place_name:,
    place_culinaries:,
  ))
}

pub fn trip_place_culinary_decoder() {
  use place_culinary_id <- toy.field("place_culinary_id", toy.string)
  use name <- toy.field("name", toy.string)
  use information_url <- toy.field(
    "information_url",
    toy.string |> toy.nullable,
  )
  use open_time <- toy.field("open_time", toy.string |> toy.nullable)
  use close_time <- toy.field("close_time", toy.string |> toy.nullable)

  toy.decoded(trip_models.PlaceCulinary(
    place_culinary_id:,
    name:,
    information_url:,
    open_time:,
    close_time:,
  ))
}
