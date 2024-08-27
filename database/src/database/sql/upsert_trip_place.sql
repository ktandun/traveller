SELECT
    upsert_trip_place (
        -- trip_place_id text
        $1,
        --trip_id text
        $2,
        -- name text
        $3,
        -- date text
        $4,
        -- google_maps_link text
        $5);

