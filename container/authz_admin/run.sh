#!/bin/bash

pip install alembic
cd /app/alembic && make schema

cd /app && authz_admin
