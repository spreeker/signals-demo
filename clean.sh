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
docker-compose down
docker-compose -f repositories/signals/docker-compose.yml down
docker-compose -f container/gemma-zaken/docker-compose.yml down
docker-compose -f repositories/gemma-zaken-demo/docker-compose.yml down

rm -rf repositories/*
