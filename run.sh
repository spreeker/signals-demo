#!/bin/bash

set -e
set -u
set -x

. ./env.sh

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

print_update () {
  echo -e "${YELLOW}$1${NOCOLOR}"
}

#print_update "Clear repositories"
##rm -rf repositories/*
#git clone https://github.com/Amsterdam/authz_admin.git repositories/authz_admin
#cp container/authz_admin/prompt-toolkit.patch repositories/authz_admin/
#cd repositories/authz_admin
# git apply prompt-toolkit.patch
#cd ../..

print_update "Up database"
docker-compose up -d database

print_update "Build authz_admin"
docker-compose build authz_admin

print_update "Wait for Postgres"
docker-compose run authz_admin /postgres-wait.sh

print_update "Create database and user for lightidp"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "CREATE DATABASE ${LIGHTIDP_PG_DB};" || true
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "CREATE USER ${LIGHTIDP_PG_USER} WITH PASSWORD '${LIGHTIDP_PG_PASSWORD}';" || true
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "GRANT ALL PRIVILEGES ON DATABASE \"${LIGHTIDP_PG_DB}\" TO ${LIGHTIDP_PG_USER};" || true

print_update "Prepare database schema for lightidp"
docker-compose exec database psql -U ${LIGHTIDP_PG_USER} ${LIGHTIDP_PG_DB} -c "CREATE TABLE IF NOT EXISTS users (email character varying(254) PRIMARY KEY, password character varying(128));" || true
docker-compose exec database psql -U ${LIGHTIDP_PG_USER} ${LIGHTIDP_PG_DB} -c "INSERT INTO users (email, password) VALUES ('${DEMO_USER_EMAIL}', '${DEMO_USER_PASS_HASH}');" || true

print_update "Up authz_admin"
docker-compose up -d authz_admin

print_update "Up lightidp"
docker-compose up -d lightidp

print_update "Wait for authz_admin"
docker-compose exec authz_admin /authz_admin-wait.sh

print_update "Up authz"
docker-compose up -d authz

#print_update "Checkout and up signals"
#git clone https://github.com/Amsterdam/signals.git repositories/signals
#docker-compose -f repositories/signals/docker-compose.yml up -d database rabbit
#docker-compose -f repositories/signals/docker-compose.yml run --rm api python manage.py migrate
#docker-compose -f repositories/signals/docker-compose.yml up -d

#print_update "Checkout and up signals-frontend"
#git clone https://github.com/Amsterdam/signals-frontend.git repositories/signals-frontend/
#cp container/signals-frontend/devsettings.patch repositories/signals-frontend/
#cd repositories/signals-frontend
#git checkout master
#git apply devsettings.patch
#npm install
#NODE_ENV=development npm start
