DELETE FROM place_activities
WHERE place_activity_id IN (
        SELECT
            pa.place_activity_id
        FROM
            user_trips ut
            INNER JOIN trip_places tp ON tp.trip_id = ut.trip_id
            INNER JOIN place_activities pa ON pa.trip_place_id = tp.trip_place_id
        WHERE
            ut.user_id = $1
            AND tp.trip_id = $2
            AND pa.trip_place_id = $3);

