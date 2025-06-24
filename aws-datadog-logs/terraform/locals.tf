locals {
  # Determine S3 bucket name
  resource_name_prefix = var.use_env_code == true ? "${lower(var.env_code)}-${lower(var.project_code)}" : "${lower(var.project_code)}"
  s3_bucket_name       = "${local.resource_name_prefix}-raw-data"
}