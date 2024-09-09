import shared/trip_models
import gleam/json
import shared/custom_decoders
import toy

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
