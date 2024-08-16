import decode
import gleam/pgo

/// A row you get from running the `find_user_by_userid` query
/// defined in `./src/traveller/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.3.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByUseridRow {
  FindUserByUseridRow(count: Int)
}

/// Runs the `find_user_by_userid` query
/// defined in `./src/traveller/sql/find_user_by_userid.sql`.
///
/// > 🐿️ This function was generated automatically using v1.3.1 of
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
    userid::text = $1
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_userid_by_email_password` query
/// defined in `./src/traveller/sql/get_userid_by_email_password.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.3.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUseridByEmailPasswordRow {
  GetUseridByEmailPasswordRow(userid: String)
}

/// Runs the `get_userid_by_email_password` query
/// defined in `./src/traveller/sql/get_userid_by_email_password.sql`.
///
/// > 🐿️ This function was generated automatically using v1.3.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_userid_by_email_password(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use userid <- decode.parameter
      GetUseridByEmailPasswordRow(userid: userid)
    })
    |> decode.field(0, decode.string)

  "SELECT
    u.userid::varchar
FROM
    users u
WHERE
    u.email = $1
    AND u.password = crypt($2, u.password)
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _),
  )
}

/// A row you get from running the `create_user` query
/// defined in `./src/traveller/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.3.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(userid: String)
}

/// Runs the `create_user` query
/// defined in `./src/traveller/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v1.3.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(db, arg_1, arg_2) {
  let decoder =
    decode.into({
      use userid <- decode.parameter
      CreateUserRow(userid: userid)
    })
    |> decode.field(0, decode.string)

  "INSERT INTO users (userid, email, PASSWORD)
    VALUES (gen_random_uuid (), $1, crypt($2, gen_salt('bf', 8)))
RETURNING
    userid::varchar
"
  |> pgo.execute(db, [pgo.text(arg_1), pgo.text(arg_2)], decode.from(decoder, _),
  )
}

/// A row you get from running the `find_user_by_email` query
/// defined in `./src/traveller/sql/find_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.3.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type FindUserByEmailRow {
  FindUserByEmailRow(count: Int)
}

/// Runs the `find_user_by_email` query
/// defined in `./src/traveller/sql/find_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v1.3.1 of
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
