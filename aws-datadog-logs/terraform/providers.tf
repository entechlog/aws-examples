terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_username
  role              = var.snowflake_role
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.snowflake_private_key_pem
  # private_key_passphrase = var.snowflake_private_key_passphrase

  disable_telemetry        = true
  preview_features_enabled = ["snowflake_table_resource"]
}