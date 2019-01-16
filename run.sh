#!/bin/bash

set -e
set -u

. ./env.sh

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

print_update () {
  echo -e "${YELLOW}$1${NOCOLOR}"
}

print_update "Up database"
docker-compose up -d database

print_update "Wait for Postgres"
docker-compose run authz_admin /postgres-wait.sh


print_update "Create database and user for lightidp"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "CREATE DATABASE ${LIGHTIDP_PG_DB};"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "CREATE USER ${LIGHTIDP_PG_USER} WITH PASSWORD '${LIGHTIDP_PG_PASSWORD}';"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "GRANT ALL PRIVILEGES ON DATABASE \"${LIGHTIDP_PG_DB}\" TO ${LIGHTIDP_PG_USER};"

print_update "Prepare database schema for lightidp"
docker-compose exec database psql -U ${LIGHTIDP_PG_USER} ${LIGHTIDP_PG_DB} -c "CREATE TABLE IF NOT EXISTS users (email character varying(254) PRIMARY KEY, password character varying(128));"
docker-compose exec database psql -U ${LIGHTIDP_PG_USER} ${LIGHTIDP_PG_DB} -c "INSERT INTO users (email, password) VALUES ('${DEMO_USER_EMAIL}', '${DEMO_USER_PASS_HASH}');"

print_update "Up authz_admin"
docker-compose up -d authz_admin

print_update "Up lightidp"
docker-compose up -d lightidp

print_update "Wait for authz_admin"
docker-compose run authz_admin /authz_admin-wait.sh

print_update "Up authz"
docker-compose up -d authz

print_update "Checkout and up signals"
rm -rf signals
git clone https://github.com/Amsterdam/signals.git
docker-compose -f signals/docker-compose.yml up -d database rabbit
docker-compose -f signals/docker-compose.yml run --rm api python manage.py migrate
docker-compose -f signals/docker-compose.yml up -d

print_update "Checkout and up signals-frontend"
rm -rf signals-frontend
git clone https://github.com/Amsterdam/signals-frontend.git
cp container/signals-frontend/devsettings.patch signals-frontend/
cd signals-frontend
git checkout master
git checkout -b devsettings
git am devsettings.patch
npm install
NODE_ENV=development npm start
