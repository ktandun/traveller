SELECT
    u.user_id
FROM
    users u
WHERE
    u.email = $1
    AND u.password = crypt($2, u.password)
