# Signals local environment
This repository contains everything to run the Signals [project][signals_repo] locally.
We check out serveral projects, patch some configuration and spin up the
neccessairy components.

For the signals backend code we spin up docker-compose from the
github.com/amsterdam/signals project

For the demo we must spin up a demo authentication service

in `env.sh` the default users are defined.

   AUTHZ_ADMIN_PG_DB=authz_admin
   AUTHZ_ADMIN_PG_USER=authz_admin
   AUTHZ_ADMIN_PG_PASSWORD=authz_admin
   AUTHZ_ADMIN_PORT=8090

   DEMO_USER_EMAIL=signals.admin@amsterdam.nl
   DEMO_USER_PASS=qwerty123

Finally we build the fronent which will use the demo authz and
signals backend.


## Requirements

- docker
- docker-compose
- npm


## Running the application

A call to ```./run.sh``` will spin up the necessary Docker containers, check out and build the
necessary repositories and initialise the database.

After completion, create the superuser as described in the README of the
Signals [repository][signals_repo].
Be aware that the container name in the command listed there
(signals) should be replaced with the name of the signals_api container in your environment
(probably signals_admin_1).


Then execute :

`docker exec -it signals python manage.py changepassword signals.admin@amsterdam.nl `



[signals_repo]: https://github.com/Amsterdam/signals
