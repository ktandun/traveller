import decode
import gleam/pgo
import youid/uuid.{type Uuid}

/// A row you get from running the `find_user_by_userid` query
/// defined in `./src/traveller/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByUseridRow {
  FindUserByUseridRow(count: Int)
}

/// Runs the `find_user_by_userid` query
/// defined in `./src/traveller/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
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
    user_id::text = $1
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `find_trip_by_trip_id` query
/// defined in `./src/traveller/sql/find_trip_by_trip_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindTripByTripIdRow {
  FindTripByTripIdRow(count: Int)
}

/// Runs the `find_trip_by_trip_id` query
/// defined in `./src/traveller/sql/find_trip_by_trip_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
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

/// A row you get from running the `get_userid_by_email_password` query
/// defined in `./src/traveller/sql/get_userid_by_email_password.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUseridByEmailPasswordRow {
  GetUseridByEmailPasswordRow(user_id: Uuid)
}

/// Runs the `get_userid_by_email_password` query
/// defined in `./src/traveller/sql/get_userid_by_email_password.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_userid_by_email_password(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use user_id <- decode.parameter
      GetUseridByEmailPasswordRow(user_id: user_id)
    })
    |> decode.field(0, uuid_decoder())

  "SELECT
    u.user_id
FROM
    users u
WHERE
    u.email = $1
    AND u.password = crypt($2, u.password)
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// A row you get from running the `create_user` query
/// defined in `./src/traveller/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(user_id: Uuid)
}

/// Runs the `create_user` query
/// defined in `./src/traveller/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use user_id <- decode.parameter
      CreateUserRow(user_id: user_id)
    })
    |> decode.field(0, uuid_decoder())

  "INSERT INTO users (user_id, email, PASSWORD)
    VALUES (gen_random_uuid (), $1, crypt($2, gen_salt('bf', 8)))
RETURNING
    user_id
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// A row you get from running the `get_user_trip_places` query
/// defined in `./src/traveller/sql/get_user_trip_places.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripPlacesRow {
  GetUserTripPlacesRow(trip_id: String, destination: String, places: String)
}

/// Runs the `get_user_trip_places` query
/// defined in `./src/traveller/sql/get_user_trip_places.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_trip_places(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use trip_id <- decode.parameter
      use destination <- decode.parameter
      use places <- decode.parameter
      GetUserTripPlacesRow(
        trip_id: trip_id,
        destination: destination,
        places: places,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)

  "WITH trip_places AS (
    SELECT
        t.trip_id::text AS trip_id,
        t.destination AS destination,
        tp.name AS name,
        tp.trip_place_id::text AS trip_place_id
    FROM
        trips t
        INNER JOIN trip_places tp ON t.trip_id = tp.trip_id
    WHERE
        t.trip_id = $2
        AND t.trip_id IN (
            SELECT
                ut.trip_id
            FROM
                user_trips ut
            WHERE
                ut.user_id = $1))
SELECT
    trip_id,
    destination,
    json_agg(json_build_object('name', name, 'trip_place_id', trip_place_id)) AS places
FROM
    trip_places
GROUP BY
    trip_id,
    destination;

"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(uuid.to_string(arg_2))],
    decode.from(decoder, _),
  )
}

/// Runs the `create_trip` query
/// defined in `./src/traveller/sql/create_trip.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_trip(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO trips (trip_id, destination)
    VALUES ($1, $2)
"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(arg_2)],
    decode.from(decoder, _),
  )
}

/// Runs the `create_user_trip` query
/// defined in `./src/traveller/sql/create_user_trip.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user_trip(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO user_trips (user_id, trip_id)
    VALUES ($1, $2);

"
  |> pgo.execute(
    db,
    [pgo.text(uuid.to_string(arg_1)), pgo.text(uuid.to_string(arg_2))],
    decode.from(decoder, _),
  )
}

/// A row you get from running the `get_user_trips` query
/// defined in `./src/traveller/sql/get_user_trips.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripsRow {
  GetUserTripsRow(trip_id: Uuid, destination: String, places_count: Int)
}

/// Runs the `get_user_trips` query
/// defined in `./src/traveller/sql/get_user_trips.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_trips(db, arg_1) {
  let decoder =
    decode.into({
      use trip_id <- decode.parameter
      use destination <- decode.parameter
      use places_count <- decode.parameter
      GetUserTripsRow(
        trip_id: trip_id,
        destination: destination,
        places_count: places_count,
      )
    })
    |> decode.field(0, uuid_decoder())
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.int)

  "SELECT
    t.trip_id,
    t.destination,
    COUNT(tp.trip_place_id) AS places_count
FROM
    trips t
    INNER JOIN trip_places tp ON t.trip_id = tp.trip_id
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
    t.destination;

"
  |> pgo.execute(db, [pgo.text(uuid.to_string(arg_1))], decode.from(decoder, _))
}

/// A row you get from running the `find_user_by_email` query
/// defined in `./src/traveller/sql/find_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.4.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByEmailRow {
  FindUserByEmailRow(count: Int)
}

/// Runs the `find_user_by_email` query
/// defined in `./src/traveller/sql/find_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v1.4.0 of
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
