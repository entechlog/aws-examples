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
  alias   = "app"
  region  = var.optional_aws_region
  profile = "dev"
}

# This provider uses the "prd" alias
provider "aws" {
  alias   = "data"
  region  = var.optional_aws_region
  profile = "prd"
}