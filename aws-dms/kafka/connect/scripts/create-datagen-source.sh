#!/bin/sh

# DataGen
cd /connect/config/source/datagen/
curl -X POST -H "Content-Type: application/json" --data @users.config http://kafka-connect:8083/connectors
curl -X POST -H "Content-Type: application/json" --data @custom_users.config http://kafka-connect:8083/connectors

# MySQL
cd /connect/config/source/mysql/
curl -X POST -H "Content-Type: application/json" --data @demo_db.config http://kafka-connect:8083/connectors
