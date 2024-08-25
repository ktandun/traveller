run: build nginx
    npx concurrently "just frontend"

clean:
    cd backend && gleam clean && rm -f manifest.toml
    cd shared && gleam clean && rm -f manifest.toml
    cd database && gleam clean && rm -f manifest.toml
    cd frontend && gleam clean && rm -f manifest.toml

build:
    cd backend && gleam build
    cd shared && gleam build
    cd database && gleam build
    cd frontend && gleam build

db:
    cd backend && dbmate drop && dbmate up
    cd database && PGUSER=kenzietandun PGDATABASE=kenzietandun gleam run -m squirrel

test: db
    cd backend && gleam test
    cd frontend && gleam test

frontend:
    cd frontend && gleam run -m lustre/dev start

backend: db
    cd backend && gleam run

nginx:
    docker rm -f nginx-proxy
    cd infra && docker build -t my-nginx-proxy . && docker run -d -p 8080:80 --name nginx-proxy my-nginx-proxy

format:
    gleam format {database,backend,shared,frontend}/{src,test}

push: format
    git push
