-- migrate:up
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

-- migrate:down
