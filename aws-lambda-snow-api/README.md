- [Snowflake API with AWS Lambda \& API Gateway](#snowflake-api-with-aws-lambda--api-gateway)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Notes](#notes)
  - [License](#license)

# Snowflake API with AWS Lambda & API Gateway

This project deploys an API that queries Snowflake using an AWS Lambda function and exposes it via API Gateway using Terraform. Snowflake credentials are securely stored in AWS Secrets Manager.

## Overview

- **Lambda Module:** Packages your Python code (with dependencies) and creates a Lambda function. The function’s handler is derived from the function name.
- **API Gateway Module:** Creates a REST API with a custom resource name (matching the Lambda function name) and constructs the full URL.
- **Secrets Manager:** Stores Snowflake credentials and is accessed by the Lambda function via a custom IAM role.

## Prerequisites

- Terraform
- AWS CLI with proper credentials
- Python 3.8 and pip (for building the deployment package)
- Docker (optional, if you choose to package via Docker)

## Usage

1. **Configure Variables:**  
   Update the variables (or tfvars file) with your AWS region, Snowflake credentials, etc.

2. **Place Lambda Code:**  
   Put your Lambda function code (e.g., get_current_timestamp.py) and requirements.txt in the designated uploads directory.

3. **Initialize and Deploy:**  
   Run:
   terraform init  
   terraform plan  
   terraform apply

4. **Test the API:**  
   The deployment outputs the full API URL (e.g., https://<rest_api_id>.execute-api.<region>.amazonaws.com/<stage>/<resource_name>). Use your browser or curl to test the endpoint.

## Notes

- The packaging process installs dependencies using pip with cross‑platform options (or via Docker for Amazon Linux 2 compatibility).
- A common IAM role (snowflake-api-lambda-role) is used for all Lambda functions.
- The API resource path is named after your function name.

## License

MIT License
