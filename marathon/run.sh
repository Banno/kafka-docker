#!/bin/bash

curl -X POST -H "Content-Type: application/json" http://localdocker:8080/v2/apps -d@marathon/kafka.json
