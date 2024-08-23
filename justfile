run: build
    cd backend && watchexec --restart --clear --quiet --no-process-group --stop-signal SIGKILL -- gleam run

clean:
    cd backend && gleam clean
    cd frontend && gleam clean

build:
    cd backend && gleam build
    cd frontend && gleam build

db:
    cd backend && dbmate drop && dbmate up

test: db
    cd backend && gleam test
    cd frontend && gleam test

format:
    gleam format {backend,shared,frontend}/{src,test}
