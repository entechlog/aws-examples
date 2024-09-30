#!/bin/sh

cd /connect/config/sink/mysql/

# DataGen
curl -X POST -H "Content-Type: application/json" --data @datagen_users.aiven.config http://kafka-connect:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @datagen_custom_users.aiven.config http://kafka-connect:8083/connectors

# Shadowtraffic
curl -X POST -H "Content-Type: application/json" --data @shadowtraffic_customers.aiven.config http://kafka-connect:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @shadowtraffic_orders.aiven.config http://kafka-connect:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @shadowtraffic_products.aiven.config http://kafka-connect:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @shadowtraffic_stores.aiven.config http://kafka-connect:8083/connectors

# Snowflake
cd /connect/config/sink/snowflake/
curl -X POST -H "Content-Type: application/json" --data @shadowtraffic_customers.config http://kafka-connect:8083/connectors
