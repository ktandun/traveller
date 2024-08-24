WITH trip_places AS (
    SELECT
        LOWER(t.trip_id::text) AS trip_id,
        t.destination AS destination,
        to_char(t.start_date, 'DD Mon YYYY') AS start_date,
        to_char(t.end_date, 'DD Mon YYYY') AS end_date,
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
    start_date,
    end_date,
    json_agg(json_build_object('name', name, 'trip_place_id', trip_place_id)) AS places
FROM
    trip_places
GROUP BY
    trip_id,
    destination,
    start_date,
    end_date;

