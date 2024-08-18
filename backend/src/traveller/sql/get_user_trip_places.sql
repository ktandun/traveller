WITH trip_places AS (
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
    json_build_object('trip_id', trip_id, 'destination', destination, 'user_trip_places', json_agg(json_build_object('name', name, 'trip_place_id', trip_place_id))) AS data
FROM
    trip_places
GROUP BY
    trip_id,
    destination;

