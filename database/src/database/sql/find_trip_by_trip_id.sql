SELECT
    count(1)
FROM
    user_trips
WHERE
    user_id = $1
    AND trip_id = $2
