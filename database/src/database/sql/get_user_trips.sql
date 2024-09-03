SELECT
    LOWER(t.trip_id::TEXT) AS trip_id,
    t.destination,
    t.start_date AS start_date,
    t.end_date AS end_date,
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

