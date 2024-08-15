-- migrate:up

CREATE TABLE users (
  userid UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255) NOT NULL
);

insert into users (userid, email, password)
values (gen_random_uuid (), 'test@example.com', 'password')

-- migrate:down

