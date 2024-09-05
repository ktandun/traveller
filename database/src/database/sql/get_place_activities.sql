SELECT
    json_build_object('trip_id', trip_id, 'trip_place_id', trip_place_id, 'place_name', place_name, 'place_activities', place_activities)
FROM
    place_activities_view ()
WHERE
    trip_id = $1
    AND trip_place_id = $2;

