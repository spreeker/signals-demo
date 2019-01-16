#!/usr/bin/env bash

set -u
set -e

# wait for authz_admin
while ! nc -z localhost 8000
do
	echo "Waiting for authz_admin..."
	sleep 2
done