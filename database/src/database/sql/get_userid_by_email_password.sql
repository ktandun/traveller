SELECT
    u.user_id::TEXT
FROM
    users u
WHERE
    u.email = $1
    AND u.password = crypt($2, u.password)
