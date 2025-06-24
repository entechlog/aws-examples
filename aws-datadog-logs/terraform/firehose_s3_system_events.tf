# System Events S3 Pipeline Instance
module "user_events_s3_pipeline" {
  source = "./modules/datadog-pipeline"

  # Required parameters
  event_name       = "system-events"
  destination_type = "s3"
  env_code         = var.env_code
  aws_region       = var.aws_region
  alert_email      = var.alert_email

  # S3 bucket configuration
  s3_bucket_name = local.s3_bucket_name

  # Buffer configuration for S3
  buffer_size     = var.s3_buffer_size
  buffer_interval = var.s3_buffer_interval

  # Datadog log filters - empty by default (filtering at Datadog level)
  datadog_log_filters = []
}