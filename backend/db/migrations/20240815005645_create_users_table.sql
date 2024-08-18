-- migrate:up
CREATE EXTENSION pgcrypto;

CREATE TABLE users (
    user_id uuid PRIMARY KEY,
    created_utc timestamp DEFAULT (timezone('utc', now())),
    email varchar(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    UNIQUE (email)
);

INSERT INTO users (user_id, email, PASSWORD)
    VALUES ('00000000-0000-0000-0000-000000000001', 'test@example.com', crypt('password', gen_salt('bf', 8))),
    ('00000000-0000-0000-0000-000000000002', 'user@example.com', crypt('password', gen_salt('bf', 8)));

CREATE TABLE trips (
    trip_id uuid PRIMARY KEY,
    destination varchar(255) NOT NULL
);

INSERT INTO trips (trip_id, destination)
    VALUES ('00000000-0000-0000-0001-000000000001', 'Singapore'),
    ('00000000-0000-0000-0001-000000000002', 'Fiji'),
    ('00000000-0000-0000-0001-000000000003', 'Canada');

CREATE TABLE user_trips (
    user_id uuid REFERENCES users (user_id),
    trip_id uuid REFERENCES trips (trip_id),
    PRIMARY KEY (user_id, trip_id)
);

INSERT INTO user_trips (trip_id, user_id)
    VALUES ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0001-000000000003', '00000000-0000-0000-0000-000000000002');

CREATE TABLE trip_places (
    trip_place_id uuid PRIMARY KEY,
    trip_id uuid REFERENCES trips (trip_id),
    name varchar(255) NOT NULL
);

INSERT INTO trip_places (trip_place_id, trip_id, name)
    VALUES ('00000000-0000-0000-0002-000000000001', '00000000-0000-0000-0001-000000000001', 'Universal Studios'),
    ('00000000-0000-0000-0002-000000000002', '00000000-0000-0000-0001-000000000001', 'Botanical Garden'),
    ('00000000-0000-0000-0002-000000000003', '00000000-0000-0000-0001-000000000001', 'Food Stalls');

-- migrate:down
