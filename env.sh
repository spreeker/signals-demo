#!/bin/bash

export LIGHTIDP_PG_USER=dpuser
export LIGHTIDP_PG_PASSWORD=dpuser
export LIGHTIDP_PG_DB=accounts
export LIGHTIDP_PORT=8088

export AUTHZ_ADMIN_PG_DB=authz_admin
export AUTHZ_ADMIN_PG_USER=authz_admin
export AUTHZ_ADMIN_PG_PASSWORD=authz_admin
export AUTHZ_ADMIN_PORT=8090

export DEMO_USER_EMAIL=signals.admin@amsterdam.nl
export DEMO_USER_PASS=qwerty123
export DEMO_USER_PASS_HASH='pbkdf2_sha256$30000$fN7ya-6Hu4Xwt2p8$Ti7h47AyNYcX4Ttf4wlgX09vcJc/kPaMSgBMTn3NQ7Q='

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

print_update () {
  echo -e "${YELLOW}$1${NOCOLOR}"
}
