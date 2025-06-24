# Create S3 bucket 
module "datadog_logs_s3" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["raw-data"]
  use_env_code   = false # We're already have different aws account for each environment
}