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


if [ ! -d "repositories/authz_admin" ]; then
  git clone https://github.com/Amsterdam/authz_admin.git repositories/authz_admin
  cp container/authz_admin/prompt-toolkit.patch repositories/authz_admin/
  cd repositories/authz_admin
  git apply prompt-toolkit.patch
  cd ../..
fi

print_update "Up database"
docker-compose up -d database

print_update "Build authz_admin"
docker-compose build authz_admin

print_update "Wait for Postgres"
docker-compose run authz_admin /postgres-wait.sh

print_update "Create database and user for lightidp"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "CREATE DATABASE ${LIGHTIDP_PG_DB};" || echo "already done"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "CREATE USER ${LIGHTIDP_PG_USER} WITH PASSWORD '${LIGHTIDP_PG_PASSWORD}';" || echo "already done"
docker-compose exec database psql -U ${AUTHZ_ADMIN_PG_USER} ${AUTHZ_ADMIN_PG_DB} -c "GRANT ALL PRIVILEGES ON DATABASE \"${LIGHTIDP_PG_DB}\" TO ${LIGHTIDP_PG_USER};" || echo "already done"

print_update "Prepare database schema for lightidp"
docker-compose exec database psql -U ${LIGHTIDP_PG_USER} ${LIGHTIDP_PG_DB} -c "CREATE TABLE IF NOT EXISTS users (email character varying(254) PRIMARY KEY, password character varying(128));" || echo "already done"
docker-compose exec database psql -U ${LIGHTIDP_PG_USER} ${LIGHTIDP_PG_DB} -c "INSERT INTO users (email, password) VALUES ('${DEMO_USER_EMAIL}', '${DEMO_USER_PASS_HASH}');" || echo "already done"

print_update "Up authz_admin"
docker-compose up -d authz_admin

print_update "Up lightidp"
docker-compose up -d lightidp

print_update "Wait for authz_admin"
docker-compose exec authz_admin /authz_admin-wait.sh

print_update "Up authz"
docker-compose up -d authz

docker-compose stop

print_update "Checkout and up signals"
if [ ! -d "repositories/signals" ]; then
  git clone https://github.com/Amsterdam/signals.git repositories/signals
fi

cd repositories/signals
git checkout featuer/demo-2019-01-24-vng-docker-compose-fix
cd ../..
docker-compose -f repositories/signals/docker-compose.yml up -d database rabbit
docker-compose -f repositories/signals/docker-compose.yml run --rm api /deploy/docker-wait.sh
docker-compose -f repositories/signals/docker-compose.yml run --rm api python manage.py migrate
docker-compose -f repositories/signals/docker-compose.yml run --rm api python manage.py createsuperuser --username 'signals.admin@amsterdam.nl' --noinput --email 'signals.admin@amsterdam.nl' || echo "already done"

docker-compose -f repositories/signals/docker-compose.yml stop

# Checking out ZDS
print_update "Checkout Gemma Zaken"
# if [ ! -d "repositories/gemma-zaken" ]; then
#   git clone https://github.com/VNG-Realisatie/gemma-zaken.git repositories/gemma-zaken
# fi

docker-compose -f container/gemma-zaken/docker-compose.yml pull
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm zrc_web python src/manage.py migrate
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm drc_web python src/manage.py migrate
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm ztc_web python src/manage.py migrate

# Add the JWT Tokens so we can talk to the components
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm zrc_web python /app/src/manage.py shell -c "from zds_schema.models import JWTSecret; JWTSecret.objects.create(secret='demo', identifier='demo')" || echo "already done"
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm drc_web python /app/src/manage.py shell -c "from zds_schema.models import JWTSecret; JWTSecret.objects.create(secret='demo', identifier='demo')" || echo "already done"
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm ztc_web python /app/src/manage.py shell -c "from zds_schema.models import JWTSecret; JWTSecret.objects.create(secret='demo', identifier='demo')" || echo "already done"

# ZRC can now talk to ZTC and DRC
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm zrc_web python /app/src/manage.py shell -c "from zds_schema.models import APICredential; APICredential.objects.create(secret='demo', client_id='demo', api_root='http:localhost:9001/api/v1/')" || echo "already done"
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm zrc_web python /app/src/manage.py shell -c "from zds_schema.models import APICredential; APICredential.objects.create(secret='demo', client_id='demo', api_root='http:localhost:9002/api/v1/')" || echo "already done"

# DRC can now talk to ZTC and ZRC
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm drc_web python /app/src/manage.py shell -c "from zds_schema.models import APICredential; APICredential.objects.create(secret='demo', client_id='demo', api_root='http:localhost:9000/api/v1/')" || echo "already done"
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm drc_web python /app/src/manage.py shell -c "from zds_schema.models import APICredential; APICredential.objects.create(secret='demo', client_id='demo', api_root='http:localhost:9002/api/v1/')" || echo "already done"
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm drc_web python /app/src/manage.py shell -c "from django.contrib.sites.shortcuts import get_current_site; site = get_current_site(); site.domain = 'localhost:9001'; site.save()" || echo "already done"

# ZTC can now talk to ZRC and DRC
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm ztc_web python /app/src/manage.py shell -c "from zds_schema.models import APICredential; APICredential.objects.create(secret='demo', client_id='demo', api_root='http:localhost:9000/api/v1/')" || echo "already done"
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm ztc_web python /app/src/manage.py shell -c "from zds_schema.models import APICredential; APICredential.objects.create(secret='demo', client_id='demo', api_root='http:localhost:9001/api/v1/')" || echo "already done"

# Loaddata for dump.json
docker-compose -f container/gemma-zaken/docker-compose.yml run --rm ztc_web python /app/src/manage.py loaddata dump.json || echo "already done"

docker-compose -f container/gemma-zaken/docker-compose.yml stop

print_update "Checkout Gemma Demo"
if [ ! -d "repositories/gemma-zaken-demo" ]; then
  git clone https://github.com/JostCrow/gemma-zaken-demo.git repositories/gemma-zaken-demo
fi

docker-compose -f repositories/gemma-zaken-demo/docker-compose.yml run --rm web python /app/src/manage.py migrate
docker-compose -f repositories/gemma-zaken-demo/docker-compose.yml run --rm web python /app/src/manage.py shell -c "from zac.demo.models import SiteConfiguration; config = SiteConfiguration.get_solo(); config.global_api_client_id='demo'; config.global_api_secret='demo'; config.zrc_base_url='http://localhost:9000/api/v1/'; config.zrc_client_id='demo'; config.zrc_secret='demo'; config.drc_base_url='http://localhost:9001/api/v1/'; config.drc_client_id='demo'; config.drc_secret='demo'; config.ztc_base_url='http://localhost:9002/api/v1/'; config.ztc_client_id='demo'; config.ztc_secret='demo'; config.ztc_catalogus_uuid='7c37e152-1447-448e-8ada-4bf0784f83db'; config.save()" || echo "already done"
docker-compose -f repositories/gemma-zaken-demo/docker-compose.yml pull


print_update "Checkout and up signals-frontend"
if [ ! -d "repositories/signals-frontend/" ]; then
  git clone https://github.com/Amsterdam/signals-frontend.git repositories/signals-frontend/
  cp container/signals-frontend/devsettings.patch repositories/signals-frontend/
fi

cd repositories/signals-frontend
git checkout master
git apply devsettings.patch || echo "already done"
rm -rf node_modules
npm install
