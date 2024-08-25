SELECT
    trip_id,
    destination,
    start_date,
    end_date,
    places
FROM
    trips_view()
WHERE
    user_id = $1
    AND trip_id = $2;

