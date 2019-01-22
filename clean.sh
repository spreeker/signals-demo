#!/bin/bash

set -e
set -u
set -x

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

print_update () {
  echo -e "${YELLOW}$1${NOCOLOR}"
}

print_update "Clear repositories"
rm -rf repositories/*

docker-compose down
docker-compose -f repositories/signals/docker-compose.yml down
docker-compose -f repositories/gemma-zaken/infra/docker-compose.hostnetwork.yml -f repositories/gemma-zaken/infra/docker-compose.yml down
