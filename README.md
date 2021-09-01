- [Overview](#overview)
- [Softwares](#softwares)
- [Demo](#demo)
  - [Start docker containers](#start-docker-containers)
  - [Validate AWS CLI and SAM](#validate-aws-cli-and-sam)
  - [Configure AWS profile](#configure-aws-profile)
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
## Start docker containers

- Clone this repo

- Open an new terminal and cd into `aws-tools` directory. This directory contains infra components for this demo

- Create a copy of [`.env.template`](/aws-tools/docker/.env.template) as `.env`
  
- Start dbt container by running
  
  ```bash
  docker-compose up -d --build
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

## Configure AWS profile

- Create an IAM user
  
- Execute below command to configure the aws profile

  ```bash
  aws configure
  ```

- Validate your profile by running
  
  ```bash
  aws configure list
  ```

## Create SAM project

- cd into your preferred directory
  
  ```bash
  cd /C/
  ```

- Create SAM project by running
  
  ```bash
  sam init
  ```

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