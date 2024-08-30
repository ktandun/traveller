run: build nginx
    npx concurrently "just frontend" "just backend"

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

buildprod:
    docker build -t traveller .
    docker run -d \
      --name traveller-postgres \
      -e POSTGRES_PASSWORD=traveller \
      -e POSTGRES_USER=traveller \
      -e POSTGRES_DB=traveller \
      -e PGDATA=/var/lib/postgresql/data/pgdata \
      -v /Users/kenzietandun/traveller-postgres:/var/lib/postgresql/data \
      -p 127.0.0.1:54322:5432 \
      postgres || true

db:
    cd backend && pkill psql; dbmate drop && dbmate up
    cd database && PGUSER=kenzietandun PGDATABASE=kenzietandun gleam run -m squirrel

test: db
    cd backend && gleam test
    cd frontend && gleam test

frontend:
    cd frontend && LUSTRE_API_BASE_URL="http://localhost:8080" gleam run -m lustre/dev start

backend: db
    cd backend && gleam run

nginx:
    docker rm -f nginx-proxy
    cd infra && docker build -t my-nginx-proxy . && docker run -d --name nginx-proxy -p 8080:8080 my-nginx-proxy

format:
    gleam format {database,backend,shared,frontend}/{src,test}
