import decode
import gleam/pgo
import youid/uuid

/// A row you get from running the `find_user_by_userid` query
/// defined in `./src/database/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByUseridRow {
  FindUserByUseridRow(count: Int)
}

/// Runs the `find_user_by_userid` query
/// defined in `./src/database/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindTripByTripIdRow {
  FindTripByTripIdRow(count: Int)
}

/// Runs the `find_trip_by_trip_id` query
/// defined in `./src/database/sql/find_trip_by_trip_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CheckUserLoginRow {
  CheckUserLoginRow(user_id: String)
}

/// Runs the `check_user_login` query
/// defined in `./src/database/sql/check_user_login.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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


/// A row you get from running the `create_user` query
/// defined in `./src/database/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(user_id: String)
}

/// Runs the `create_user` query
/// defined in `./src/database/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripPlacesRow {
  GetUserTripPlacesRow(
    trip_id: String,
    destination: String,
    start_date: String,
    end_date: String,
    places: String,
  )
}

/// Runs the `get_user_trip_places` query
/// defined in `./src/database/sql/get_user_trip_places.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
      GetUserTripPlacesRow(
        trip_id: trip_id,
        destination: destination,
        start_date: start_date,
        end_date: end_date,
        places: places,
      )
    })
    |> decode.field(0, decode.string)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.string)

  "SELECT
    trip_id,
    destination,
    start_date,
    end_date,
    places
FROM
    trips_view()
WHERE
    user_id = $1
    AND trip_id = $2;

"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _),
  )
}


/// A row you get from running the `create_trip` query
/// defined in `./src/database/sql/create_trip.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateTripRow {
  CreateTripRow(create_trip: String)
}

/// Runs the `create_trip` query
/// defined in `./src/database/sql/create_trip.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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


/// Runs the `delete_trip_place` query
/// defined in `./src/database/sql/delete_trip_place.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserTripsRow {
  GetUserTripsRow(
    trip_id: String,
    destination: String,
    start_date: String,
    end_date: String,
    places_count: Int,
  )
}

/// Runs the `get_user_trips` query
/// defined in `./src/database/sql/get_user_trips.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.int)

  "SELECT
    LOWER(t.trip_id::TEXT) AS trip_id,
    t.destination,
    to_char(t.start_date, 'DD Mon YYYY') AS start_date,
    to_char(t.end_date, 'DD Mon YYYY') AS end_date,
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
/// > 🐿️ This type definition was generated automatically using v1.5.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByEmailRow {
  FindUserByEmailRow(count: Int)
}

/// Runs the `find_user_by_email` query
/// defined in `./src/database/sql/find_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v1.5.0 of
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
