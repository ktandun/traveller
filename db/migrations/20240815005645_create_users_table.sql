-- migrate:up
CREATE EXTENSION pgcrypto;

CREATE TABLE users (
    userid uuid PRIMARY KEY,
    email varchar(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    UNIQUE (email)
);

INSERT INTO users (userid, email, PASSWORD)
    VALUES ('49bee8c8-3a1d-4ec8-9d28-ba6d863df62e', 'test@example.com', crypt('password', gen_salt('bf', 8)))

-- migrate:down
