-- migrate:up
CREATE TABLE users (
    user_id uuid PRIMARY KEY,
    created_utc timestamp DEFAULT timezone('utc', now()),
    email varchar(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    UNIQUE (email)
);

CREATE TABLE trips (
    trip_id uuid PRIMARY KEY,
    destination varchar(255) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);

CREATE TABLE user_trips (
    user_id uuid REFERENCES users (user_id),
    trip_id uuid REFERENCES trips (trip_id),
    PRIMARY KEY (user_id, trip_id)
);

CREATE TABLE trip_places (
    trip_place_id uuid PRIMARY KEY,
    trip_id uuid REFERENCES trips (trip_id) NOT NULL,
    name varchar(255) NOT NULL,
    date date NOT NULL,
    google_maps_link text
);

CREATE TABLE trip_companions (
    trip_companion_id uuid PRIMARY KEY,
    trip_id uuid REFERENCES trips (trip_id) NOT NULL,
    name varchar(255) NOT NULL,
    email varchar(255) NOT NULL
);

CREATE OR REPLACE FUNCTION create_trip (user_id text, trip_id text, destination text, start_date text, end_date text)
    RETURNS text
    AS $f$
BEGIN
    INSERT INTO trips (trip_id, destination, start_date, end_date)
        VALUES (create_trip.trip_id::uuid, create_trip.destination, create_trip.start_date::date, create_trip.end_date::date);
    --
    INSERT INTO user_trips (user_id, trip_id)
        VALUES (create_trip.user_id::uuid, create_trip.trip_id::uuid);
    --
    RETURN create_trip.trip_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION delete_trip_companions (trip_id text)
    RETURNS text
    AS $f$
BEGIN
    DELETE FROM trip_companions tc
    WHERE tc.trip_id = delete_trip_companions.trip_id::uuid;
    --
    RETURN 'OK';
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION upsert_trip_companion (trip_companion_id text, trip_id text, name text, email text)
    RETURNS text
    AS $f$
BEGIN
    IF NOT EXISTS (
        SELECT
            1
        FROM
            trip_companions tc
        WHERE
            tc.trip_companion_id = upsert_trip_companion.trip_companion_id::uuid) THEN
    INSERT INTO trip_companions (trip_companion_id, trip_id, name, email)
    SELECT
        upsert_trip_companion.trip_companion_id::uuid,
        upsert_trip_companion.trip_id::uuid,
        upsert_trip_companion.name,
        upsert_trip_companion.email;
ELSE
    UPDATE
        trip_companions tc
    SET
        name = upsert_trip_companion.name,
        email = upsert_trip_companion.email
    WHERE
        tc.trip_companion_id = upsert_trip_companion.trip_companion_id::uuid;
END IF;
    --
    RETURN upsert_trip_companion.trip_companion_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION upsert_trip_place (trip_place_id text, trip_id text, name text, date text, google_maps_link text)
    RETURNS text
    AS $f$
BEGIN
    IF NOT EXISTS (
        SELECT
            1
        FROM
            trip_places tp
        WHERE
            tp.trip_place_id = upsert_trip_place.trip_place_id::uuid) THEN
    INSERT INTO trip_places (trip_place_id, trip_id, name, date, google_maps_link)
    SELECT
        upsert_trip_place.trip_place_id::uuid,
        upsert_trip_place.trip_id::uuid,
        upsert_trip_place.name,
        upsert_trip_place.date::date,
        upsert_trip_place.google_maps_link;
ELSE
    UPDATE
        trip_places tp
    SET
        name = upsert_trip_place.name,
        date = upsert_trip_place.date::date,
        google_maps_link = upsert_trip_place.google_maps_link
    WHERE
        tp.trip_place_id = upsert_trip_place.trip_place_id::uuid;
END IF;
    --
    RETURN upsert_trip_place.trip_place_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION trips_view ()
    RETURNS TABLE (
        user_id uuid,
        trip_id uuid,
        destination varchar(255),
        start_date text,
        end_date text,
        places json,
        companions json
    )
    AS $f$
BEGIN
    RETURN QUERY WITH companions AS (
        SELECT
            tc.trip_id,
            json_agg(json_build_object('trip_companion_id', tc.trip_companion_id, 'name', name, 'email', tc.email)) AS companions
        FROM
            trip_companions tc
        GROUP BY
            tc.trip_id
),
places AS (
    SELECT
        tp.trip_id,
        json_agg(json_build_object('trip_place_id', tp.trip_place_id, 'name', tp.name, 'date', to_char(tp.date, 'YYYY-MM-DD'), 'google_maps_link', tp.google_maps_link)) AS places
    FROM
        trip_places tp
    GROUP BY
        tp.trip_id
),
trips AS (
    SELECT
        ut.user_id AS user_id,
        t.trip_id AS trip_id,
        t.destination AS destination,
        to_char(t.start_date, 'YYYY-MM-DD') AS start_date,
        to_char(t.end_date, 'YYYY-MM-DD') AS end_date
    FROM
        user_trips ut
        LEFT JOIN trips t ON ut.trip_id = t.trip_id
    ORDER BY
        t.start_date ASC
)
SELECT
    tp.user_id,
    tp.trip_id,
    tp.destination,
    tp.start_date,
    tp.end_date,
    coalesce(p.places, '[]'::json) AS places,
    COALESCE(c.companions, '[]'::json) AS companions
FROM
    trips tp
    LEFT JOIN companions c ON tp.trip_id = c.trip_id
    LEFT JOIN places p ON tp.trip_id = p.trip_id;
END;
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION check_user_login (email text, PASSWORD TEXT)
    RETURNS text
    AS $f$
BEGIN
    RETURN (
        SELECT
            u.user_id
        FROM
            users u
        WHERE
            u.email = check_user_login.email
            AND u.password = CRYPT(check_user_login.PASSWORD, u.password)
        LIMIT 1);
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION create_user (user_id text, email text, PASSWORD TEXT)
    RETURNS VOID
    AS $f$
BEGIN
    INSERT INTO users (user_id, email, PASSWORD)
        VALUES (create_user.user_id::uuid, create_user.email, create_user.password);
END
$f$
LANGUAGE PLPGSQL;

SELECT
    create_user (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', email => 'test@example.com', PASSWORD => crypt('password', gen_salt('bf', 8)));

SELECT
    create_user (user_id => 'abc5bc96-e6e4-48ed-aa47-aa08082f0382', email => 'user@example.com', PASSWORD => crypt('password', gen_salt('bf', 8)));

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', destination => 'Singapore', start_date => '2024-01-01', end_date => '2024-01-31');

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '38933aaa-d41f-4a99-b8a7-f1dfd7e95c86', destination => 'Bali', start_date => '2024-08-01', end_date => '2024-09-01');

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '14794e0a-9a80-4be6-b9b1-070f094ca06c', destination => 'Fiji', start_date => '2024-02-01', end_date => '2024-02-14');

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '6dc47c9e-f363-4c0b-afbb-d3324a4e8d59', destination => 'Canada', start_date => '2024-03-01', end_date => '2024-03-28');

SELECT
    upsert_trip_place (trip_place_id => '619ee043-d377-4ef7-8134-dc16c3c4af99', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Unversal Studios', date => '2024-01-01', google_maps_link => 'https://maps.app.goo.gl/ztxEEUqyuoHvSUEu8');

SELECT
    upsert_trip_place (trip_place_id => '65916ea8-c637-4921-89a0-97d3661ce782', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Botanical Garden', date => '2024-01-02', google_maps_link => 'https://maps.app.goo.gl/GCjgJNFi8zYUHvzv7');

SELECT
    upsert_trip_place (trip_place_id => 'a99f7893-632a-41fb-bd40-2f8fe8dd1d7e', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Food Stalls', date => '2024-01-03', google_maps_link => NULL);

SELECT
    upsert_trip_companion (trip_companion_id => '7fccacf1-1f38-49ad-b9de-b3a9788508e1', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Noel', email => 'noel@gmail.com');

SELECT
    upsert_trip_companion (trip_companion_id => '8D9102DD-747C-4E2A-B867-00C3A701D30C', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Senchou', email => 'senchou@gmail.com');

-- migrate:down
DROP TABLE trip_places;

DROP TABLE user_trips;

DROP TABLE trips;

DROP TABLE users;

