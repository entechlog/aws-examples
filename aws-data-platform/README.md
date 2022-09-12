- [Overview](#overview)
- [Start container](#start-container)
- [References](#references)
  - [MSK](#msk)
  - [MWAA](#mwaa)
- [Feature wish list](#feature-wish-list)
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
- [What's New with AWS MSK](https://aws.amazon.com/about-aws/whats-new/2022/?whats-new-content-all.sort-by=item.additionalFields.postDateTime&whats-new-content-all.sort-order=desc&awsf.whats-new-analytics=general-products%23amazon-msk&awsf.whats-new-app-integration=*all&awsf.whats-new-arvr=*all&awsf.whats-new-blockchain=*all&awsf.whats-new-business-applications=*all&awsf.whats-new-cloud-financial-management=*all&awsf.whats-new-compute=*all&awsf.whats-new-containers=*all&awsf.whats-new-customer-enablement=*all&awsf.whats-new-customer%20engagement=*all&awsf.whats-new-database=*all&awsf.whats-new-developer-tools=*all&awsf.whats-new-end-user-computing=*all&awsf.whats-new-mobile=*all&awsf.whats-new-gametech=*all&awsf.whats-new-iot=*all&awsf.whats-new-machine-learning=*all&awsf.whats-new-management-governance=*all&awsf.whats-new-media-services=*all&awsf.whats-new-migration-transfer=*all&awsf.whats-new-networking-content-delivery=*all&awsf.whats-new-quantum-tech=*all&awsf.whats-new-robotics=*all&awsf.whats-new-satellite=*all&awsf.whats-new-security-id-compliance=*all&awsf.whats-new-serverless=*all&awsf.whats-new-storage=*all)

## MWAA
- https://github.com/claudiobizzotto/aws-mwaa-terraform-private
- https://github.com/claudiobizzotto/aws-mwaa-terraform
- https://docs.aws.amazon.com/mwaa/latest/userguide/access-policies.html
- https://itnext.io/amazon-managed-workflows-for-apache-airflow-configuration-77db7fd633c5
- https://dev.to/aws/working-with-permissions-in-amazon-managed-workflows-for-apache-airflow-2g5l
- https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-env-variables.html
- https://stackoverflow.com/questions/67788083/mwaa-airflow-2-0-in-aws-snowflake-connection-not-showing
- https://docs.aws.amazon.com/mwaa/latest/userguide/connections-secrets-manager.html
- https://catalog.us-east-1.prod.workshops.aws/workshops/795e88bb-17e2-498f-82d1-2104f4824168/en-US/workshop-2-2-2/setup/s3

# Feature wish list
## MSK

| Feature                                                | Status  |
| ------------------------------------------------------ | ------- |
| Fix the MSK service_execution_role_arn                 | ✔️       |
| Disable MSK unauthenticated access and test connectors | ✔️       |
| Create an EC2 instance to test scram auth              | Pending |
| Install Kafka UI in ECS                                | Pending |

## MWAA
| Feature                                                                                                       | Status | Notes                                                                                  |
| ------------------------------------------------------------------------------------------------------------- | ------ | -------------------------------------------------------------------------------------- |
| [Role for MWAA users to grant access](https://docs.aws.amazon.com/mwaa/latest/userguide/access-policies.html) | ✔️      |                                                                                        |
| Custom Image                                                                                                  | ✔️      | Done using requirements                                                                |
| Variables                                                                                                     | ✔️      | See https://docs.aws.amazon.com/mwaa/latest/userguide/samples-variables-import.html    |
| Snowflake connection                                                                                          | ✔️      | See https://docs.aws.amazon.com/mwaa/latest/userguide/connections-secrets-manager.html |
| Cloud watch log group                                                                                         | ✔️      | Will be same as cluster name, No option to customize                                   |