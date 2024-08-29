SELECT
    upsert_trip_companion (
        -- trip_companion_id TEXT
        $1,
        -- trip_id TEXT
        $2,
        -- name TEXT
        $3,
        -- email TEXT
        $4);

