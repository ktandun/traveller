SELECT
    count(1)
FROM
    users
WHERE
    userid::text = $1
