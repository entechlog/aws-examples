#!/bin/sh

cd /connect/config/source/

curl -X POST -H "Content-Type: application/json" --data @connector_src_users.config http://kafka-connect:8083/connectors

curl -X POST -H "Content-Type: application/json" --data @connector_src_custom_users.config http://kafka-connect:8083/connectors