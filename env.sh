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

# SIA setup to connect to ZDS
HOST_URL=localhost:8000

ZTC_HOST=localhost
ZTC_PORT=9002
ZTC_SCHEME=http
ZTC_CLIENT_ID=demo  # do psql magic to set these
ZTC_CLIENT_SECRET=demo

ZTC_CATALOGUS_ID=7c37e152-1447-448e-8ada-4bf0784f83db  # set via script in ZTC db
ZTC_ZAAKTYPE_ID=249e28bc-f635-42aa-8d09-879490223150
ZTC_INFORMATIEOBJECTTYPE_ID=9ec5f29f-5d97-4914-9e0f-e801a4f63f0e


ZRC_HOST=localhost
ZRC_PORT=9000
ZRC_SCHEME=http
ZRC_CLIENT_ID=demo
ZRC_CLIENT_SECRET=demo


DRC_HOST=localhost
DRC_PORT=9001
DRC_SCHEME=http
DRC_CLIENT_ID=demo
DRC_CLIENT_SECRET=demo

