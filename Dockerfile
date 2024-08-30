FROM ghcr.io/gleam-lang/gleam:v1.4.1-erlang

WORKDIR /app
COPY . .

WORKDIR /app/backend
RUN gleam build

WORKDIR /app/frontend
RUN mv src/env.gleam.prod src/env.gleam
RUN gleam run -m lustre/dev build app

WORKDIR /app
RUN cp frontend/priv/static/frontend.mjs backend/priv/static/
RUN cp frontend/index.html backend/priv/static/
RUN sed -i 's|<script type="module" src="/priv/static/frontend\.mjs"></script>|<script type="module" src="/frontend.mjs"></script>|' backend/priv/static/index.html

WORKDIR /app/backend

ENV DEPLOY_ENV="Production"
ENV DATABASE_USER="traveller"
ENV DATABASE_PASS="traveller"
ENV DATABASE_DB="traveller"
ENV DATABASE_HOST="traveller-postgres"
ENV DATABASE_PORT="5432"
ENV DATABASE_URL="postgres://$DATABASE_USER:$DATABASE_PASS@$DATABASE_HOST:$DATABASE_PORT/$DATABASE_DB?sslmode=disable"

EXPOSE 8000

ENTRYPOINT ["gleam", "run"]
