- [Overview](#overview)
- [Start container](#start-container)
- [References](#references)
  - [MSK](#msk)
  - [MWAA](#mwaa)
- [Pending](#pending)
  - [MSK](#msk-1)
  - [MWAA](#mwaa-1)
  
# Overview
Terraform template to create a simple data platform with VPC, Subnets, Airflow(MWAA) and Kafka(MSK)

# Start container

- Bring up the development container by running
  ```bash
  docker-compose up -d --build
  ```

- Create AWS profile by running
  ```bash
  aws configure --profile terraform
  ```

- Create resources by running   
  ```bash
  terraform apply
  ```

- Bring up the development container by running
  ```bash
  docker-compose down -v --remove-orphans
  ```
  
# References
## MSK
- https://github.com/vinamra1502/terraform-work/tree/main/terraform-module/msk
- https://github.com/msfidelis/aws-msk-glue-kafka-setup
- https://www.davidc.net/sites/default/subnets/subnets.html
- https://search.maven.org/artifact/org.mongodb.kafka/mongo-kafka-connect/1.7.0/jar
- https://repo1.maven.org/maven2/com/snowflake/snowflake-kafka-connector/1.8.0/
- https://medium.com/appgambit/terraform-aws-vpc-with-private-public-subnets-with-nat-4094ad2ab331
- https://aws.amazon.com/blogs/apn/connecting-applications-securely-to-a-mongodb-atlas-data-plane-with-aws-privatelink/
- https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-internet-access.html

## MWAA
- https://github.com/claudiobizzotto/aws-mwaa-terraform-private
- https://github.com/claudiobizzotto/aws-mwaa-terraform
- https://docs.aws.amazon.com/mwaa/latest/userguide/access-policies.html


# Pending
## MSK
- Fix the MSK service_execution_role_arn
- Create an EC2 instance
- Disable MSK unauthenticated access and test connectors and Kafka UI

## MWAA
- Role for MWAA users 
- Custom Image
- Variables
- Snowflake connection