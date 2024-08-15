INSERT INTO users (userid, email, password)
    VALUES (gen_random_uuid(), $1, $2)
RETURNING
    userid::varchar
