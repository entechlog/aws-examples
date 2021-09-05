- [Overview](#overview)
- [Softwares](#softwares)
- [Demo](#demo)
  - [Create AWS IAM user](#create-aws-iam-user)
  - [Start docker containers](#start-docker-containers)
  - [Validate AWS CLI and SAM](#validate-aws-cli-and-sam)
  - [Create SAM project](#create-sam-project)
  - [Deploy SAM project to AWS](#deploy-sam-project-to-aws)
  - [Clean the demo resources](#clean-the-demo-resources)
- [References](#references)

# Overview
AWS SAM Lambda demo

# Softwares
We will use the following 

- [`AWS CLI`](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed in docker container
- [`AWS SAM`](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) installed in docker container
- Python 3.8

> Docker containers will give us standardized platform for development.

# Demo

## Create AWS IAM user

- Create an IAM user in AWS with required access to create and delete AWS resources like S3, Lambda, API Gateway, CloudFormation.
- Create an access key for this IAM user. The access key will be used to by SAM to deploy the resources.
  
## Start docker containers

- Clone this repo

- Open an new terminal and cd into `aws-tools` directory. This directory contains infra components for this demo

- Create a copy of [`.env.template`](/aws-tools/docker/.env.template) as `.env`

- Update the `.env` with the access key from [previous step](#create-aws-iam-user)
  
- Start aws-tools container by running
  
  ```bash
  docker-compose up -d
  ```

- Validate the container by running

  ```bash
  docker ps
  ```
  
## Validate AWS CLI and SAM

- SSH into the container by running

  ```bash
  docker exec -it aws-tools /bin/bash
  ```

- Validate AWS CLI by running
  
  ```bash
  aws --version
  ```

- Validate AWS SAM by running
  
  ```bash
  sam --version
  ```

- Validate your AWS profile by running
  
  ```bash
  aws configure list
  ```
  
  > You can also override the profile OR create a new profile by running at anypoint by running

  ```bash
  aws configure
  OR
  aws configure --profile <profile-name>
  ```

## Create SAM project

- cd into your preferred directory
  
  ```bash
  cd /C/
  ```

- Create SAM project by running and following the guided instructions
  
  ```bash
  sam init
  ```

  > This can be also done by invoking following one-liner commands
  > ```
  > sam init --name sam-lambda-api --runtime python3.9 --dependency-manager pip --app-template hello-world --no-interactive
  > sam init --name sam-step-app --runtime python3.9 --dependency-manager pip --app-template step-functions-sample-app --no-interactive
  > ```

- Validate SAM project by running

  ```bash
  sam validate
  ```
  
- Build SAM project by running

  ```bash
  sam build
  ```

- Invoke SAM project locally by running

  ```bash
  sam local invoke --container-host host.docker.internal
  ```

- Start Lambda locally by running

  ```bash
  sam local start-lambda --container-host host.docker.internal --host 0.0.0.0
  ```

- Invoke Lambda by running below command from a new session

  ```bash
  aws lambda invoke --function-name "HelloWorldFunction" --endpoint-url "http://localhost:3001" --no-verify-ssl lamda_output.txt && cat lamda_output.txt
  ```

- Start API locally by running

  ```bash
  sam local start-api --container-host host.docker.internal --host 0.0.0.0
  ```

- Invoke API by hitting below URL from a browser OR postman

  ```bash
  http://localhost:3000/hello
  ```

## Deploy SAM project to AWS

- Deploy SAM project by running below command

  ```bash
  sam deploy --guided
  ```

## Clean the demo resources
Open an new terminal and cd into `aws-tools` directory. Run below command to delete the docker containers and related volumes

```bash
docker-compose down --volume --remove-orphans
```

# References
- https://github.com/aws/aws-sam-cli/issues/2899
- https://avdi.codes/aws-sam-in-a-docker-dev-container/