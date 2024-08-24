SELECT
    count(1)
FROM
    users
WHERE
    user_id = $1
