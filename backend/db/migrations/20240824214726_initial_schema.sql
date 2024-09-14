-- migrate:up
--------------------------------------------------------
----------------- TABLES -------------------------------
--------------------------------------------------------
CREATE TABLE users (
    user_id uuid PRIMARY KEY,
    created_utc timestamp DEFAULT timezone('utc', now()),
    email text NOT NULL,
    password text NOT NULL,
    session_token uuid,
    login_timestamp timestamp,
    UNIQUE (email),
    UNIQUE (session_token)
);

CREATE TABLE trips (
    trip_id uuid PRIMARY KEY,
    destination text NOT NULL,
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
    name text NOT NULL,
    date date NOT NULL
);

CREATE TABLE trip_companions (
    trip_companion_id uuid PRIMARY KEY,
    trip_id uuid REFERENCES trips (trip_id) NOT NULL,
    name text NOT NULL,
    email text NOT NULL
);

CREATE TABLE place_activities (
    place_activity_id uuid PRIMARY KEY,
    trip_place_id uuid REFERENCES trip_places (trip_place_id) NOT NULL,
    name text NOT NULL,
    information_url text,
    start_time time(0) without time zone,
    end_time time(0) without time zone,
    entry_fee numeric(18, 2)
);

CREATE TABLE place_culinaries (
    place_culinary_id uuid PRIMARY KEY,
    trip_place_id uuid REFERENCES trip_places (trip_place_id) NOT NULL,
    name text NOT NULL,
    information_url text,
    open_time time(0) without time zone,
    close_time time(0) without time zone
);

CREATE TABLE place_accomodations (
    place_accomodation_id uuid PRIMARY KEY,
    trip_place_id uuid REFERENCES trip_places (trip_place_id) NOT NULL UNIQUE,
    name text NOT NULL,
    information_url text,
    accomodation_fee numeric(18, 2),
    paid bool DEFAULT FALSE
);

--------------------------------------------------------
----------------- FUNCTIONS ----------------------------
--------------------------------------------------------
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

CREATE OR REPLACE FUNCTION upsert_place_culinary (place_culinary_id text, trip_place_id text, name text, information_url text, open_time text, close_time text)
    RETURNS text
    AS $f$
BEGIN
    IF NOT EXISTS (
        SELECT
            1
        FROM
            place_culinaries pculi
        WHERE
            pculi.place_culinary_id = upsert_place_culinary.place_culinary_id::uuid) THEN
    INSERT INTO place_culinaries (place_culinary_id, trip_place_id, name, information_url, open_time, close_time)
    SELECT
        upsert_place_culinary.place_culinary_id::uuid,
        upsert_place_culinary.trip_place_id::uuid,
        upsert_place_culinary.name,
        upsert_place_culinary.information_url,
        upsert_place_culinary.open_time::time,
        upsert_place_culinary.close_time::time;
ELSE
    UPDATE
        place_culinaries pculi
    SET
        name = upsert_place_culinary.name,
        information_url = upsert_place_culinary.information_url,
        open_time = upsert_place_culinary.open_time::time,
        close_time = upsert_place_culinary.close_time::time
    WHERE
        pculi.trip_place_id = upsert_place_culinary.trip_place_id::uuid
        AND pculi.place_culinary_id = upsert_place_culinary.place_culinary_id::uuid;
END IF;
    --
    RETURN upsert_place_culinary.place_culinary_id;
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

CREATE OR REPLACE FUNCTION upsert_trip_place (trip_place_id text, trip_id text, name text, date text)
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
    INSERT INTO trip_places (trip_place_id, trip_id, name, date)
    SELECT
        upsert_trip_place.trip_place_id::uuid,
        upsert_trip_place.trip_id::uuid,
        upsert_trip_place.name,
        upsert_trip_place.date::date;
ELSE
    UPDATE
        trip_places tp
    SET
        name = upsert_trip_place.name,
        date = upsert_trip_place.date::date
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
        destination text,
        start_date date,
        end_date date,
        total_activities_fee numeric,
        total_accomodations_fee numeric,
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
culinaries_count AS (
    SELECT
        tp.trip_place_id,
        COUNT(pculi.place_culinary_id) AS count
    FROM
        trip_places tp
        LEFT JOIN place_culinaries pculi ON tp.trip_place_id = pculi.trip_place_id
    GROUP BY
        tp.trip_place_id
),
activities_count AS (
    SELECT
        tp.trip_place_id,
        COUNT(pactiv.place_activity_id) AS count
    FROM
        trip_places tp
        LEFT JOIN place_activities pactiv ON tp.trip_place_id = pactiv.trip_place_id
    GROUP BY
        tp.trip_place_id
),
trip_places_ordered_by_date AS (
    SELECT
        *
    FROM
        trip_places tp
    ORDER BY
        tp.date
),
places AS (
    SELECT
        tp.trip_id,
        json_agg(json_build_object('trip_place_id', tp.trip_place_id, 'name', tp.name, 'date', to_char(tp.date, 'YYYY-MM-DD'), 'has_accomodation', paccom.place_accomodation_id IS NOT NULL, 'accomodation_paid', coalesce(paccom.paid, FALSE), 'activities_count', act_count.count, 'culinaries_count', cul_count.count)) AS places
FROM
    trip_places_ordered_by_date tp
    LEFT JOIN place_accomodations paccom ON tp.trip_place_id = paccom.trip_place_id
        LEFT JOIN activities_count act_count ON tp.trip_place_id = act_count.trip_place_id
        LEFT JOIN culinaries_count cul_count ON tp.trip_place_id = cul_count.trip_place_id
    GROUP BY
        tp.trip_id
),
fees_aggregate AS (
    SELECT
        utrip.trip_id,
        SUM(coalesce(pactiv.entry_fee, 0)) AS total_activities_fee,
    SUM(coalesce(paccom.accomodation_fee, 0)) AS total_accomodations_fee
FROM
    user_trips utrip
    LEFT JOIN trip_places tplac ON utrip.trip_id = tplac.trip_id
        LEFT JOIN place_activities pactiv ON tplac.trip_place_id = pactiv.trip_place_id
        LEFT JOIN place_accomodations paccom ON tplac.trip_place_id = paccom.trip_place_id
    GROUP BY
        utrip.trip_id
),
trips AS (
    SELECT
        ut.user_id AS user_id,
        t.trip_id AS trip_id,
        t.destination AS destination,
        t.start_date AS start_date,
        t.end_date AS end_date
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
    fee_agg.total_activities_fee,
    fee_agg.total_accomodations_fee,
    coalesce(p.places, '[]'::json) AS places,
    coalesce(c.companions, '[]'::json) AS companions
FROM
    trips tp
    LEFT JOIN companions c ON tp.trip_id = c.trip_id
    LEFT JOIN places p ON tp.trip_id = p.trip_id
    LEFT JOIN fees_aggregate fee_agg ON fee_agg.trip_id = tp.trip_id;
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

CREATE OR REPLACE FUNCTION update_trip (trip_id text, destination text, start_date text, end_date text)
    RETURNS text
    AS $f$
BEGIN
    UPDATE
        trips
    SET
        destination = update_trip.destination,
        start_date = update_trip.start_date::date,
        end_date = update_trip.end_date::date
    WHERE
        trips.trip_id = update_trip.trip_id::uuid;
    --
    RETURN update_trip.trip_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION create_place_activity (place_activity_id text, trip_place_id text, name text, information_url text, start_time text, end_time text, entry_fee numeric)
    RETURNS text
    AS $f$
BEGIN
    INSERT INTO place_activities (place_activity_id, trip_place_id, name, information_url, start_time, end_time, entry_fee)
    SELECT
        create_place_activity.place_activity_id::uuid,
        create_place_activity.trip_place_id::uuid,
        create_place_activity.name,
        create_place_activity.information_url,
        create_place_activity.start_time::time,
        create_place_activity.end_time::time,
        create_place_activity.entry_fee;
    --
    RETURN create_place_activity.place_activity_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION place_activities_view ()
    RETURNS TABLE (
        trip_id uuid,
        trip_place_id uuid,
        place_name text,
        place_activities json
    )
    AS $f$
BEGIN
    RETURN QUERY WITH activities_ordered_by_end_time AS (
        SELECT
            *
        FROM
            place_activities
        ORDER BY
            end_time
),
activities AS (
    SELECT
        pa.trip_place_id,
        json_agg(json_build_object('place_activity_id', pa.place_activity_id, 'name', pa.name, 'information_url', pa.information_url, 'start_time', TO_CHAR(pa.start_time, 'HH24:MI'), 'end_time', TO_CHAR(pa.end_time, 'HH24:MI'), 'entry_fee', pa.entry_fee)) AS activities
FROM
    activities_ordered_by_end_time pa
GROUP BY
    pa.trip_place_id
)
SELECT
    tp.trip_id,
    tp.trip_place_id,
    tp.name AS place_name,
    coalesce(a.activities, '[]'::json) AS place_activities
FROM
    trip_places tp
    LEFT JOIN activities a ON a.trip_place_id = tp.trip_place_id;
END;
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION trip_place_accomodations_view ()
    RETURNS TABLE (
        place_accomodation_id uuid,
        trip_place_id uuid,
        place_name text,
        accomodation_name text,
        information_url text,
        accomodation_fee numeric,
        paid bool
    )
    AS $f$
BEGIN
    RETURN QUERY
    SELECT
        paccom.place_accomodation_id,
        paccom.trip_place_id,
        tplac.name AS place_name,
        paccom.name AS accomodation_name,
        paccom.information_url,
        paccom.accomodation_fee,
        paccom.paid
    FROM
        place_accomodations paccom
        INNER JOIN trip_places tplac ON paccom.trip_place_id = tplac.trip_place_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION upsert_place_accomodation (trip_place_id text, place_accomodation_id text, accomodation_name text, information_url text, accomodation_fee numeric, paid bool)
    RETURNS text
    AS $f$
BEGIN
    IF NOT EXISTS (
        SELECT
            1
        FROM
            place_accomodations paccom
        WHERE
            paccom.place_accomodation_id = upsert_place_accomodation.place_accomodation_id::uuid
            AND paccom.trip_place_id = upsert_place_accomodation.trip_place_id::uuid) THEN
    INSERT INTO place_accomodations (place_accomodation_id, trip_place_id, name, information_url, accomodation_fee, paid)
    SELECT
        upsert_place_accomodation.place_accomodation_id::uuid,
        upsert_place_accomodation.trip_place_id::uuid,
        upsert_place_accomodation.accomodation_name,
        upsert_place_accomodation.information_url,
        upsert_place_accomodation.accomodation_fee,
        upsert_place_accomodation.paid;
ELSE
    UPDATE
        place_accomodations paccom
    SET
        name = upsert_place_accomodation.accomodation_name,
        information_url = upsert_place_accomodation.information_url,
        accomodation_fee = upsert_place_accomodation.accomodation_fee,
        paid = upsert_place_accomodation.paid
    WHERE
        paccom.place_accomodation_id = upsert_place_accomodation.place_accomodation_id::uuid
        AND paccom.trip_place_id = upsert_place_accomodation.trip_place_id::uuid;
END IF;
    --
    RETURN upsert_place_accomodation.place_accomodation_id;
END
$f$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION trip_place_culinaries_view ()
    RETURNS TABLE (
        trip_id uuid,
        trip_place_id uuid,
        place_name text,
        place_culinaries json
    )
    AS $f$
BEGIN
    RETURN QUERY WITH culinaries AS (
        SELECT
            pculi.trip_place_id,
            json_agg(json_build_object('place_culinary_id', pculi.place_culinary_id, 'name', pculi.name, 'information_url', pculi.information_url, 'open_time', TO_CHAR(pculi.open_time, 'HH24:MI'), 'close_time', TO_CHAR(pculi.close_time, 'HH24:MI'))) AS culinaries
        FROM
            place_culinaries pculi
        GROUP BY
            pculi.trip_place_id
)
    SELECT
        tp.trip_id,
        tp.trip_place_id,
        tp.name AS place_name,
        coalesce(c.culinaries, '[]'::json) AS place_culinaries
FROM
    trip_places tp
    LEFT JOIN culinaries c ON c.trip_place_id = tp.trip_place_id;
END;
$f$
LANGUAGE PLPGSQL;

------------------------------------------------------
----------------- SEED -------------------------------
------------------------------------------------------
SELECT
    create_user (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', email => 'test@example.com', PASSWORD => crypt('password', gen_salt('bf', 8)));

UPDATE
    users
SET
    session_token = 'fb9d5701-f1e1-4b86-8dfd-f51722677ced',
    login_timestamp = timezone('utc', now())
WHERE
    user_id = 'ab995595-008e-4ab5-94bb-7845f5d48626';

SELECT
    create_user (user_id => 'abc5bc96-e6e4-48ed-aa47-aa08082f0382', email => 'user@example.com', PASSWORD => crypt('password', gen_salt('bf', 8)));

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', destination => 'Singapore', start_date => CURRENT_DATE::text, end_date => (CURRENT_DATE + interval '1 month')::text);

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '38933aaa-d41f-4a99-b8a7-f1dfd7e95c86', destination => 'Bali', start_date => '2024-08-01', end_date => '2024-09-01');

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '14794e0a-9a80-4be6-b9b1-070f094ca06c', destination => 'Fiji', start_date => '2024-02-01', end_date => '2024-02-14');

SELECT
    create_trip (user_id => 'ab995595-008e-4ab5-94bb-7845f5d48626', trip_id => '6dc47c9e-f363-4c0b-afbb-d3324a4e8d59', destination => 'Canada', start_date => '2024-03-01', end_date => '2024-03-28');

SELECT
    upsert_trip_place (trip_place_id => '619ee043-d377-4ef7-8134-dc16c3c4af99', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Universal Studios', date => CURRENT_DATE::text);

SELECT
    upsert_trip_place (trip_place_id => '65916ea8-c637-4921-89a0-97d3661ce782', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Botanical Garden', date => (CURRENT_DATE + make_interval(days => 1))::text);

SELECT
    upsert_trip_place (trip_place_id => 'a99f7893-632a-41fb-bd40-2f8fe8dd1d7e', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Food Stalls', date => (CURRENT_DATE + make_interval(days => 2))::text);

SELECT
    upsert_trip_companion (trip_companion_id => '7fccacf1-1f38-49ad-b9de-b3a9788508e1', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Noel', email => 'noel@gmail.com');

SELECT
    upsert_trip_companion (trip_companion_id => '8D9102DD-747C-4E2A-B867-00C3A701D30C', trip_id => '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', name => 'Senchou', email => 'senchou@gmail.com');

SELECT
    create_place_activity (place_activity_id => 'c26a0603-16d2-4156-b985-acf398b16cd2', trip_place_id => '619ee043-d377-4ef7-8134-dc16c3c4af99', name => 'Battlestar Galactica: HUMAN vs. CYLON', information_url => 'https://www.sentosa.com.sg/en/things-to-do/attractions/universal-studios-singapore/', start_time => '10:00', end_time => '12:00', entry_fee => 3);

SELECT
    create_place_activity (place_activity_id => '5035f7ca-82e1-41ed-ba23-68a3ff53d47f', trip_place_id => '619ee043-d377-4ef7-8134-dc16c3c4af99', name => 'TRANSFORMERS The Ride: The Ultimate 3D Battle', information_url => 'https://www.sentosa.com.sg/en/things-to-do/attractions/universal-studios-singapore/', start_time => '12:00', end_time => '13:00', entry_fee => 12);

SELECT
    upsert_place_accomodation (trip_place_id => '619ee043-d377-4ef7-8134-dc16c3c4af99', place_accomodation_id => '58cc6f2b-4291-4396-bf4f-5102f8fce4fe', accomodation_name => 'Marina Bay Sands', information_url => 'https://www.marinabaysands.com', accomodation_fee => 120, paid => TRUE);

SELECT
    upsert_place_culinary (trip_place_id => '619ee043-d377-4ef7-8134-dc16c3c4af99', place_culinary_id => 'd8e8ab96-6ed7-4210-903c-79c21534686f', name => 'SKAI', information_url => 'https://www.tripadvisor.co.nz/Restaurant_Review-g294265-d15123886-Reviews-SKAI-Singapore.html', open_time => '10:00', close_time => '23:00');

SELECT
    upsert_place_culinary (trip_place_id => '65916ea8-c637-4921-89a0-97d3661ce782', place_culinary_id => 'ebc82287-6f34-4689-bc8d-6d92143448da', name => 'Waterfall Ristorante', information_url => 'https://www.tripadvisor.co.nz/Restaurant_Review-g294265-d3952172-Reviews-Waterfall_Ristorante_Italiano-Singapore.html', open_time => '12:00', close_time => '14:30');

-- migrate:down
DROP FUNCTION trips_view ();

DROP FUNCTION trip_place_culinaries_view ();

DROP FUNCTION check_user_login (email text, PASSWORD TEXT);

DROP FUNCTION create_user (user_id text, email text, PASSWORD TEXT);

DROP FUNCTION update_trip (trip_id text, destination text, start_date text, end_date text);

DROP FUNCTION create_place_activity (place_activity_id text, trip_place_id text, name text, information_url text, start_time text, end_time text, entry_fee numeric);

DROP FUNCTION place_activities_view ();

DROP FUNCTION trip_place_accomodations_view ();

DROP FUNCTION upsert_place_accomodation (trip_place_id text, place_accomodation_id text, accomodation_name text, information_url text, accomodation_fee numeric, paid bool);

DROP TABLE place_culinaries;

DROP TABLE place_accomodations;

DROP TABLE place_activities;

DROP TABLE trip_places;

DROP TABLE trip_companions;

DROP TABLE user_trips;

DROP TABLE trips;

DROP TABLE users;

