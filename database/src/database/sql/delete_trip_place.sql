DELETE FROM trip_places
WHERE trip_id IN (
        SELECT
            ut.trip_id
        FROM
            user_trips ut
        WHERE
            ut.user_id = $1
            AND ut.trip_id = $2)
    AND trip_place_id = $3;

