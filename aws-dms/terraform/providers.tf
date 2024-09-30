terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}

# This is the "default" provider
provider "aws" {
  region  = var.optional_aws_region
  profile = "dev"
}