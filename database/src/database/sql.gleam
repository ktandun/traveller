import decode
import gleam/pgo
import youid/uuid.{type Uuid}

/// A row you get from running the `find_user_by_userid` query
/// defined in `./src/database/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByUseridRow {
  FindUserByUseridRow(count: Int)
}

/// Runs the `find_user_by_userid` query
/// defined in `./src/database/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_user_by_userid(db, arg_1) {
  let decoder =
    decode.into({
      use count <- decode.parameter
      FindUserByUseridRow(count: count)
    })
    |> decode.field(0, decode.int)

  "SELECT
    count(1)
FROM
    users
WHERE
    user_id = $1
"
  |> pgo.execute(db, [pgo.text(uuid.to_string(arg_1))], decode.from(decoder, _))
}


/// A row you get from running the `find_trip_by_trip_id` query
/// defined in `./src/database/sql/find_trip_by_trip_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindTripByTripIdRow {
  FindTripByTripIdRow(count: Int)
}

/// Runs the `find_trip_by_trip_id` query
/// defined in `./src/database/sql/find_trip_by_trip_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_trip_by_trip_id(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use count <- decode.parameter
      FindTripByTripIdRow(count: count)
    })
    |> decode.field(0, decode.int)

  "SELECT
    count(1)
FROM
    user_trips
WHERE
    user_id = $1
    AND trip_id = $2
"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(uuid.to_string(arg_2))],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `check_user_login` query
/// defined in `./src/database/sql/check_user_login.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CheckUserLoginRow {
  CheckUserLoginRow(user_id: String)
}

/// Runs the `check_user_login` query
/// defined in `./src/database/sql/check_user_login.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn check_user_login(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use user_id <- decode.parameter
      CheckUserLoginRow(user_id: user_id)
    })
    |> decode.field(0, decode.string)

  "SELECT
    check_user_login ($1, $2) AS user_id;

"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _),
  )
}


/// A row you get from running the `upsert_trip_companion` query
/// defined in `./src/database/sql/upsert_trip_companion.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpsertTripCompanionRow {
  UpsertTripCompanionRow(upsert_trip_companion: String)
}

/// Runs the `upsert_trip_companion` query
/// defined in `./src/database/sql/upsert_trip_companion.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn upsert_trip_companion(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder =
    decode.into({
      use upsert_trip_companion <- decode.parameter
      UpsertTripCompanionRow(upsert_trip_companion: upsert_trip_companion)
    })
    |> decode.field(0, decode.string)

  "SELECT
    upsert_trip_companion (
        -- trip_companion_id TEXT
        $1,
        -- trip_id TEXT
        $2,
        -- name TEXT
        $3,
        -- email TEXT
        $4);

"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.text(arg_2), pgo.text(arg_3), pgo.text(arg_4)],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `create_place_activity` query
/// defined in `./src/database/sql/create_place_activity.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreatePlaceActivityRow {
  CreatePlaceActivityRow(create_place_activity: String)
}

/// Runs the `create_place_activity` query
/// defined in `./src/database/sql/create_place_activity.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_place_activity(db, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7,
) {
  let decoder =
    decode.into({
      use create_place_activity <- decode.parameter
      CreatePlaceActivityRow(create_place_activity: create_place_activity)
    })
    |> decode.field(0, decode.string)

  "SELECT
    create_place_activity (
        --place_activity_id text,
        $1,
        --trip_place_id text,
        $2,
        --name text,
        $3,
        --information_url text,
        $4,
        --start_time text,
        $5,
        --end_time text,
        $6,
        --entry_fee text
        $7);

"
  |> pgo.execute(
    db,
    [
      pgo.text(arg_1),
      pgo.text(arg_2),
      pgo.text(arg_3),
      pgo.text(arg_4),
      pgo.text(arg_5),
      pgo.text(arg_6),
      pgo.text(arg_7),
    ],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `get_user_trip_dates_by_trip_id` query
/// defined in `./src/database/sql/get_user_trip_dates_by_trip_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripDatesByTripIdRow {
  GetUserTripDatesByTripIdRow(
    start_date: #(Int, Int, Int),
    end_date: #(Int, Int, Int),
  )
}

/// Runs the `get_user_trip_dates_by_trip_id` query
/// defined in `./src/database/sql/get_user_trip_dates_by_trip_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_trip_dates_by_trip_id(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use start_date <- decode.parameter
      use end_date <- decode.parameter
      GetUserTripDatesByTripIdRow(start_date: start_date, end_date: end_date)
    })
    |> decode.field(0, date_decoder())
    |> decode.field(1, date_decoder())

  "SELECT
    start_date,
    end_date
FROM
    trips_view ()
WHERE
    user_id = $1
    AND trip_id = $2;

"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(uuid.to_string(arg_2))],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `delete_trip_companions` query
/// defined in `./src/database/sql/delete_trip_companions.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type DeleteTripCompanionsRow {
  DeleteTripCompanionsRow(delete_trip_companions: String)
}

/// Runs the `delete_trip_companions` query
/// defined in `./src/database/sql/delete_trip_companions.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_trip_companions(db, arg_1) {
  let decoder =
    decode.into({
      use delete_trip_companions <- decode.parameter
      DeleteTripCompanionsRow(delete_trip_companions: delete_trip_companions)
    })
    |> decode.field(0, decode.string)

  "SELECT
    delete_trip_companions (
        -- trip_id
        $1);

"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}


/// A row you get from running the `create_user` query
/// defined in `./src/database/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(user_id: String)
}

/// Runs the `create_user` query
/// defined in `./src/database/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use user_id <- decode.parameter
      CreateUserRow(user_id: user_id)
    })
    |> decode.field(0, decode.string)

  "INSERT INTO users (user_id, email, PASSWORD)
    VALUES (gen_random_uuid (), $1, crypt($2, gen_salt('bf', 8)))
RETURNING
    user_id::TEXT
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _),
  )
}


/// A row you get from running the `get_user_trip_places` query
/// defined in `./src/database/sql/get_user_trip_places.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripPlacesRow {
  GetUserTripPlacesRow(
    trip_id: Uuid,
    destination: String,
    start_date: #(Int, Int, Int),
    end_date: #(Int, Int, Int),
    places: String,
    companions: String,
  )
}

/// Runs the `get_user_trip_places` query
/// defined in `./src/database/sql/get_user_trip_places.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_trip_places(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use trip_id <- decode.parameter
      use destination <- decode.parameter
      use start_date <- decode.parameter
      use end_date <- decode.parameter
      use places <- decode.parameter
      use companions <- decode.parameter
      GetUserTripPlacesRow(
        trip_id: trip_id,
        destination: destination,
        start_date: start_date,
        end_date: end_date,
        places: places,
        companions: companions,
      )
    })
    |> decode.field(0, uuid_decoder())
    |> decode.field(1, decode.string)
    |> decode.field(2, date_decoder())
    |> decode.field(3, date_decoder())
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.string)

  "SELECT
    trip_id,
    destination,
    start_date,
    end_date,
    places,
    companions
FROM
    trips_view ()
WHERE
    user_id = $1
    AND trip_id = $2;

"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(uuid.to_string(arg_2))],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `find_trip_by_trip_place_id` query
/// defined in `./src/database/sql/find_trip_by_trip_place_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindTripByTripPlaceIdRow {
  FindTripByTripPlaceIdRow(count: Int)
}

/// Runs the `find_trip_by_trip_place_id` query
/// defined in `./src/database/sql/find_trip_by_trip_place_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_trip_by_trip_place_id(db, arg_1, arg_2, arg_3) {
  let decoder =
    decode.into({
      use count <- decode.parameter
      FindTripByTripPlaceIdRow(count: count)
    })
    |> decode.field(0, decode.int)

  "SELECT
    count(1)
FROM
    user_trips ut
    INNER JOIN trip_places tp ON ut.trip_id = tp.trip_id
WHERE
    ut.user_id = $1
    AND ut.trip_id = $2
    AND tp.trip_place_id = $3
"
  |> pgo.execute(
    db,
    [
      pgo.text(uuid.to_string(arg_1)),
      pgo.text(uuid.to_string(arg_2)),
      pgo.text(uuid.to_string(arg_3)),
    ],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `create_trip` query
/// defined in `./src/database/sql/create_trip.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateTripRow {
  CreateTripRow(create_trip: String)
}

/// Runs the `create_trip` query
/// defined in `./src/database/sql/create_trip.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_trip(db, arg_1, arg_2, arg_3, arg_4, arg_5) {
  let decoder =
    decode.into({
      use create_trip <- decode.parameter
      CreateTripRow(create_trip: create_trip)
    })
    |> decode.field(0, decode.string)

  "SELECT
    create_trip ($1, $2, $3, $4, $5);

"
  |> pgo.execute(
    db,
    [
      pgo.text(arg_1),
      pgo.text(arg_2),
      pgo.text(arg_3),
      pgo.text(arg_4),
      pgo.text(arg_5),
    ],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `upsert_trip_place` query
/// defined in `./src/database/sql/upsert_trip_place.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpsertTripPlaceRow {
  UpsertTripPlaceRow(upsert_trip_place: String)
}

/// Runs the `upsert_trip_place` query
/// defined in `./src/database/sql/upsert_trip_place.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn upsert_trip_place(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder =
    decode.into({
      use upsert_trip_place <- decode.parameter
      UpsertTripPlaceRow(upsert_trip_place: upsert_trip_place)
    })
    |> decode.field(0, decode.string)

  "SELECT
    upsert_trip_place (
        -- trip_place_id text
        $1,
        --trip_id text
        $2,
        -- name text
        $3,
        -- date text
        $4);

"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.text(arg_2), pgo.text(arg_3), pgo.text(arg_4)],
    decode.from(decoder, _),
  )
}


/// Runs the `delete_place_activities` query
/// defined in `./src/database/sql/delete_place_activities.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_place_activities(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM place_activities
WHERE place_activity_id IN (
        SELECT
            pa.place_activity_id
        FROM
            user_trips ut
            INNER JOIN trip_places tp ON tp.trip_id = ut.trip_id
            INNER JOIN place_activities pa ON pa.trip_place_id = tp.trip_place_id
        WHERE
            ut.user_id = $1
            AND tp.trip_id = $2
            AND pa.trip_place_id = $3);

"
  |> pgo.execute(
    db,
    [
      pgo.text(uuid.to_string(arg_1)),
      pgo.text(uuid.to_string(arg_2)),
      pgo.text(uuid.to_string(arg_3)),
    ],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `update_trip` query
/// defined in `./src/database/sql/update_trip.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type UpdateTripRow {
  UpdateTripRow(update_trip: String)
}

/// Runs the `update_trip` query
/// defined in `./src/database/sql/update_trip.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_trip(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder =
    decode.into({
      use update_trip <- decode.parameter
      UpdateTripRow(update_trip: update_trip)
    })
    |> decode.field(0, decode.string)

  "SELECT
    update_trip (
        -- trip_id text
        $1,
        -- destination text
        $2,
        -- start_date text
        $3,
        -- end_date text
        $4);

"
  |> pgo.execute(
    db,
    [pgo.text(arg_1), pgo.text(arg_2), pgo.text(arg_3), pgo.text(arg_4)],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `get_place_activities` query
/// defined in `./src/database/sql/get_place_activities.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetPlaceActivitiesRow {
  GetPlaceActivitiesRow(json_build_object: String)
}

/// Runs the `get_place_activities` query
/// defined in `./src/database/sql/get_place_activities.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_place_activities(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use json_build_object <- decode.parameter
      GetPlaceActivitiesRow(json_build_object: json_build_object)
    })
    |> decode.field(0, decode.string)

  "SELECT
    json_build_object('trip_id', trip_id, 'trip_place_id', trip_place_id, 'place_name', place_name, 'place_activities', place_activities)
FROM
    place_activities_view ()
WHERE
    trip_id = $1
    AND trip_place_id = $2;

"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(uuid.to_string(arg_2))],
    decode.from(decoder, _),
  )
}


/// Runs the `delete_trip_place` query
/// defined in `./src/database/sql/delete_trip_place.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_trip_place(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM trip_places
WHERE trip_id IN (
        SELECT
            ut.trip_id
        FROM
            user_trips ut
        WHERE
            ut.user_id = $1
            AND ut.trip_id = $2)
    AND trip_place_id = $3;

"
  |> pgo.execute(
    db,
    [
      pgo.text(uuid.to_string(arg_1)),
      pgo.text(uuid.to_string(arg_2)),
      pgo.text(uuid.to_string(arg_3)),
    ],
    decode.from(decoder, _),
  )
}


/// A row you get from running the `get_user_trips` query
/// defined in `./src/database/sql/get_user_trips.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripsRow {
  GetUserTripsRow(
    trip_id: String,
    destination: String,
    start_date: #(Int, Int, Int),
    end_date: #(Int, Int, Int),
    places_count: Int,
  )
}

/// Runs the `get_user_trips` query
/// defined in `./src/database/sql/get_user_trips.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_trips(db, arg_1) {
  let decoder =
    decode.into({
      use trip_id <- decode.parameter
      use destination <- decode.parameter
      use start_date <- decode.parameter
      use end_date <- decode.parameter
      use places_count <- decode.parameter
      GetUserTripsRow(
        trip_id: trip_id,
        destination: destination,
        start_date: start_date,
        end_date: end_date,
        places_count: places_count,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, date_decoder())
    |> decode.field(3, date_decoder())
    |> decode.field(4, decode.int)

  "SELECT
    LOWER(t.trip_id::TEXT) AS trip_id,
    t.destination,
    t.start_date AS start_date,
    t.end_date AS end_date,
    COUNT(tp.trip_place_id) AS places_count
FROM
    trips t
    LEFT JOIN trip_places tp ON t.trip_id = tp.trip_id
WHERE
    t.trip_id IN (
        SELECT
            ut.trip_id
        FROM
            user_trips ut
        WHERE
            ut.user_id = $1)
GROUP BY
    t.trip_id,
    t.destination,
    t.start_date,
    t.end_date
ORDER BY
    t.start_date ASC;

"
  |> pgo.execute(db, [pgo.text(uuid.to_string(arg_1))], decode.from(decoder, _))
}


/// A row you get from running the `find_user_by_email` query
/// defined in `./src/database/sql/find_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.6.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByEmailRow {
  FindUserByEmailRow(count: Int)
}

/// Runs the `find_user_by_email` query
/// defined in `./src/database/sql/find_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v1.6.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn find_user_by_email(db, arg_1) {
  let decoder =
    decode.into({
      use count <- decode.parameter
      FindUserByEmailRow(count: count)
    })
    |> decode.field(0, decode.int)

  "SELECT
    1 as count
FROM
    users
WHERE
    email = $1
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}


// --- UTILS -------------------------------------------------------------------

/// A decoder to decode `date`s coming from a Postgres query.
///
fn date_decoder() {
  use dynamic <- decode.then(decode.dynamic)
  case pgo.decode_date(dynamic) {
    Ok(date) -> decode.into(date)
    Error(_) -> decode.fail("date")
  }
}

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  decode.then(decode.bit_array, fn(uuid) {
    case uuid.from_bit_array(uuid) {
      Ok(uuid) -> decode.into(uuid)
      Error(_) -> decode.fail("uuid")
    }
  })
}
