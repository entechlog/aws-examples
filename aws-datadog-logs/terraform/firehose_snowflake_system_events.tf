# System Events Snowflake Pipeline Instance
module "system_events_snowflake_pipeline" {
  source = "./modules/datadog-pipeline"

  # Required parameters
  event_name       = "system-events"
  destination_type = "snowflake"
  env_code         = var.env_code
  aws_region       = var.aws_region
  alert_email      = var.alert_email

  # Buffer configuration for Snowflake
  buffer_size     = var.snowflake_buffer_size
  buffer_interval = var.snowflake_buffer_interval

  # S3 bucket configuration
  s3_bucket_name = local.s3_bucket_name

  # Datadog log filters - empty by default (filtering at Datadog level)
  datadog_log_filters = []

  # Snowflake configuration
  snowflake_account_url = var.snowflake_account_url
  snowflake_username    = var.snowflake_username
  snowflake_database    = var.snowflake_database
  snowflake_schema      = var.snowflake_schema
  snowflake_role        = var.snowflake_role
  snowflake_private_key = var.snowflake_private_key
}