-- migrate:up
CREATE EXTENSION pgcrypto;

CREATE TABLE users (
    userid uuid PRIMARY KEY,
    created_utc timestamp DEFAULT (timezone('utc', now())),
    email varchar(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    UNIQUE (email)
);

INSERT INTO users (userid, email, PASSWORD)
    VALUES ('00000000-0000-0000-0000-000000000001', 'test@example.com', crypt('password', gen_salt('bf', 8))),
    ('00000000-0000-0000-0000-000000000002', 'user@example.com', crypt('password', gen_salt('bf', 8)));

CREATE TABLE trips (
    tripid uuid PRIMARY KEY,
    destination varchar(255) NOT NULL
);

CREATE TABLE user_trips (
    userid uuid REFERENCES users (userid),
    tripid uuid REFERENCES trips (tripid),
    PRIMARY KEY (userid, tripid)
);

INSERT INTO trips (tripid, destination)
    VALUES ('6a81d19f-0387-4990-9b74-f9302ba20e81', 'Fiji'),
    ('79bac422-dae5-4e17-8833-87ccfad525ed', 'Singapore'),
    ('ddbc8ff1-1f82-43fa-81f7-e49cc141c1a9', 'Canada');

INSERT INTO user_trips (tripid, userid)
    VALUES ('6a81d19f-0387-4990-9b74-f9302ba20e81', '00000000-0000-0000-0000-000000000001'),
    ('79bac422-dae5-4e17-8833-87ccfad525ed', '00000000-0000-0000-0000-000000000001'),
    ('ddbc8ff1-1f82-43fa-81f7-e49cc141c1a9', '00000000-0000-0000-0000-000000000002');

-- migrate:down
