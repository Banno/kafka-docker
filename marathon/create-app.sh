#!/bin/bash

if [ "$#" -ne 1 ]; then
      echo "script takes json file as an argument"
  exit 1;
fi
MARATHON_HOST="localdocker"
MARATHON_PORT="8080"
curl -X POST -H "Content-Type: application/json" http://${MARATHON_HOST}:${MARATHON_PORT}/v2/apps -d@"$@"
