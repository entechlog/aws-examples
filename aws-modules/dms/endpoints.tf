# Define the source endpoint
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "src-${var.source_engine_name}-${var.source_identifier}"
  endpoint_type = "source"
  engine_name   = var.source_engine_name
  username      = var.source_username
  password      = var.source_password
  server_name   = var.source_server_name
  port          = var.source_port
}

# Define the target endpoint for non-S3 targets
resource "aws_dms_endpoint" "target" {
  count = var.target_engine_name == "s3" ? 0 : 1

  endpoint_id   = "tgt-${var.target_engine_name}-${var.target_identifier}"
  endpoint_type = "target"
  engine_name   = var.target_engine_name
  username      = var.target_username
  password      = var.target_password
  server_name   = var.target_server_name
  port          = var.target_port
}

# Define the target endpoint for S3
resource "aws_dms_s3_endpoint" "target_s3" {
  count = var.target_engine_name == "s3" ? 1 : 0

  endpoint_id             = "tgt-s3-${var.target_identifier}"
  endpoint_type           = "target"
  bucket_name             = var.target_bucket_name
  bucket_folder           = var.target_bucket_folder
  service_access_role_arn = var.target_service_access_role_arn

  # Data format and partitioning settings
  data_format             = var.target_data_format
  date_partition_enabled  = var.target_date_partition_enabled
  date_partition_sequence = var.target_partition_sequence
}
