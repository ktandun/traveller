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
    VALUES
        --
        ('ab995595-008e-4ab5-94bb-7845f5d48626', 'test@example.com', crypt('password', gen_salt('bf', 8))),
        ('abc5bc96-e6e4-48ed-aa47-aa08082f0382', 'user@example.com', crypt('password', gen_salt('bf', 8)));

CREATE TABLE trips (
    trip_id uuid PRIMARY KEY,
    destination varchar(255) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);

INSERT INTO trips (trip_id, destination, start_date, end_date)
    VALUES
        --
        ('87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', 'Singapore', '2024-01-01', '2024-01-31'),
        ('38933aaa-d41f-4a99-b8a7-f1dfd7e95c86', 'Bali', '2024-08-01', '2024-09-01'),
        ('14794e0a-9a80-4be6-b9b1-070f094ca06c', 'Fiji', '2024-02-01', '2024-02-14'),
        ('6dc47c9e-f363-4c0b-afbb-d3324a4e8d59', 'Canada', '2024-03-01', '2024-03-28');

CREATE TABLE user_trips (
    user_id uuid REFERENCES users (user_id),
    trip_id uuid REFERENCES trips (trip_id),
    PRIMARY KEY (user_id, trip_id)
);

INSERT INTO user_trips (trip_id, user_id)
    VALUES
        --
        ('87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', 'ab995595-008e-4ab5-94bb-7845f5d48626'),
        ('38933aaa-d41f-4a99-b8a7-f1dfd7e95c86', 'ab995595-008e-4ab5-94bb-7845f5d48626'),
        ('14794e0a-9a80-4be6-b9b1-070f094ca06c', 'ab995595-008e-4ab5-94bb-7845f5d48626'),
        ('6dc47c9e-f363-4c0b-afbb-d3324a4e8d59', 'abc5bc96-e6e4-48ed-aa47-aa08082f0382');

CREATE TABLE trip_places (
    trip_place_id uuid PRIMARY KEY,
    trip_id uuid REFERENCES trips (trip_id),
    name varchar(255) NOT NULL
);

INSERT INTO trip_places (trip_place_id, trip_id, name)
    VALUES
        --
        ('619ee043-d377-4ef7-8134-dc16c3c4af99', '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', 'Universal Studios'),
        ('65916ea8-c637-4921-89a0-97d3661ce782', '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', 'Botanical Garden'),
        ('a99f7893-632a-41fb-bd40-2f8fe8dd1d7e', '87fccf2c-dbeb-4e6f-b116-5f46463c2ee7', 'Food Stalls');

-- migrate:down
