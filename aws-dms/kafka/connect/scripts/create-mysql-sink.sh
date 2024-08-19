#!/bin/sh

cd /connect/config/sink/

#curl -X POST -H "Content-Type: application/json" --data @connector_sink_users.confluent.config http://kafka-connect:8083/connectors

curl -X POST -H "Content-Type: application/json" --data @connector_sink_users.aiven.config http://kafka-connect:8083/connectors

curl -X POST -H "Content-Type: application/json" --data @connector_sink_custom_users.aiven.config http://kafka-connect:8083/connectors
