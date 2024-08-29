SELECT
    start_date,
    end_date
FROM
    trips_view ()
WHERE
    user_id = $1
    AND trip_id = $2;

