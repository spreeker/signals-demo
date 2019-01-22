docker-compose down
docker-compose -f repositories/signals/docker-compose.yml down
docker-compose -f repositories/gemma-zaken/infra/docker-compose.yml -f repositories/gemma-zaken/infra/docker-compose.hostnetwork.yml down
