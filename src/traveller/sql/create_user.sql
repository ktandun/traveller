INSERT INTO users (userid, email, PASSWORD)
    VALUES (gen_random_uuid (), $1, crypt($2, gen_salt('bf', 8)))
RETURNING
    userid::varchar
