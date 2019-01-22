#!/bin/bash

set -e
set -u
set -x

. ./env.sh

docker-compose up -d
docker-compose -f repositories/signals/docker-compose.yml up -d
docker-compose -f repositories/gemma-zaken/infra/docker-compose.hostnetwork.yml -f repositories/gemma-zaken/infra/docker-compose.yml up -d

cd repositories/signals-frontend
NODE_ENV=development npm start
