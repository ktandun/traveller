SELECT
    u.userid::varchar
FROM
    users u
WHERE
    u.email = $1
    AND u.password = $2
