run: build
    cd backend && watchexec -r -e gleam -E DEVELOPMENT=true -- gleam run

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

frontend:
    cd frontend && gleam run -m lustre/dev start
