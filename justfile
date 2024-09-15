set dotenv-required

export DEPLOY_ENV := "Development"
export DATABASE_HOST := "localhost"
export DATABASE_PORT := "5432"
export DATABASE_USER := "kenzietandun"
export DATABASE_PASS := "password"
export DATABASE_DB := "kenzietandun"

run: build
    npx concurrently "just nginx" "just frontend" "just backend"

clean:
    cd backend && gleam clean && rm -f manifest.toml
    cd shared && gleam clean && rm -f manifest.toml
    cd frontend && gleam clean && rm -f manifest.toml

build:
    cd backend && gleam build
    cd shared && gleam build
    cd frontend && gleam build

buildprod:
    docker compose down
    docker compose build
    docker compose up --no-start
    docker compose start traveller-postgres
    sleep 5
    cd backend && dbmate -e PRODUCTION_DATABASE_URL drop
    cd backend && dbmate -e PRODUCTION_DATABASE_URL up
    docker compose up

db:
    cd backend && dbmate drop && dbmate up

test: db
    cd backend && gleam test
    #cd frontend && gleam test

frontend:
    cd frontend && LUSTRE_API_BASE_URL="http://localhost:8080" gleam run -m lustre/dev start

backend: db
    cd backend && gleam run

nginx:
    docker rm -f nginx-proxy
    cd infra && docker build -t my-nginx-proxy . && docker run -d --name nginx-proxy -p 8080:8080 my-nginx-proxy

format:
    gleam format {backend,shared,frontend}/{src,test}
