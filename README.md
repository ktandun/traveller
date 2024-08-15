# traveller

A website to help organise travels with friends and families

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Database Migrations

Reset the database

```sh
dbmate drop && dbmate up
```

Run migration


```sh
dbmate migrate
```

## SQL Codegen with squirrel

```sh
PGUSER=kenzietandun PGDATABASE=kenzietandun gleam run -m squirrel
```

## Snapshot testing with birdie

```sh
gleam run -m birdie
```
