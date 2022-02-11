# sam-lambda-xml2json

## Overview
Demo for creating MSK cluster using AWS SAM/CloudFormation

## SAM commands
- SAM Build 
  ```
  sam build
  ```

- SAM Deploy
  ```bash
  sam deploy --guided
  
  sam deploy --stack-name sam-msk-cluster --s3-bucket <sam-bucket-name> --capabilities CAPABILITY_NAMED_IAM
  ```
  
- Delete the stack
  ```bash
  aws cloudformation delete-stack --stack-name sam-msk-cluster
  ```