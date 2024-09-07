SELECT
    count(1)
FROM
    user_trips ut
    INNER JOIN trip_places tp ON ut.trip_id = tp.trip_id
WHERE
    ut.user_id = $1
    AND ut.trip_id = $2
    AND tp.trip_place_id = $3
