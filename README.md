# Signals local environment
This repository contains everything to run the Signals [project][signals_repo] locally. Besides
the front,- and backend, this also includes the authentication and authorisation chain.


## Requirements

- docker
- docker-compose
- npm

## Running the application 

A call to ```./run.sh``` will spin up the necessary Docker containers, check out and build the
necessary repositories and initialise the database.

After completion, create the signals.admin@amsterdam.nl user as described in the README of the
Signals [repository][signals_repo]. Be aware that the container name in the command listed there
(signals) should be replaced with the name of the signals_api container in your environment
(probably signals_admin_1).


[signals_repo]: https://github.com/Amsterdam/signals