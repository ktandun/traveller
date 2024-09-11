SELECT
    trip_id,
    destination,
    start_date,
    end_date,
    total_activities_fee,
    total_accomodations_fee,
    places,
    companions
FROM
    trips_view ()
WHERE
    user_id = $1
    AND trip_id = $2;

