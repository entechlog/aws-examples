locals {
  delivery_stream_name = var.use_env_code ? "${var.delivery_stream_name}-${terraform.workspace}" : var.delivery_stream_name
}

# IAM role for Firehose
resource "aws_iam_role" "firehose_delivery_role" {
  name = "${local.delivery_stream_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for S3 access (only when destination is S3)
resource "aws_iam_role_policy" "firehose_s3_policy" {
  count = var.destination_type == "s3" ? 1 : 0
  name  = "${local.delivery_stream_name}-firehose-s3-policy"
  role  = aws_iam_role.firehose_delivery_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM policy for Snowflake access (includes S3 for backup)
resource "aws_iam_role_policy" "firehose_snowflake_policy" {
  count = var.destination_type == "snowflake" ? 1 : 0
  name  = "${local.delivery_stream_name}-firehose-snowflake-policy"
  role  = aws_iam_role.firehose_delivery_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name              = "/aws/kinesisfirehose/${local.delivery_stream_name}"
  retention_in_days = 7

  tags = var.tags
}

# CloudWatch Log Stream for S3
resource "aws_cloudwatch_log_stream" "firehose_s3_log_stream" {
  count          = var.destination_type == "s3" ? 1 : 0
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
}

# CloudWatch Log Stream for Snowflake
resource "aws_cloudwatch_log_stream" "firehose_snowflake_log_stream" {
  count          = var.destination_type == "snowflake" ? 1 : 0
  name           = "SnowflakeDelivery"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group.name
}

# Kinesis Firehose Delivery Stream for S3
resource "aws_kinesis_firehose_delivery_stream" "s3_delivery_stream" {
  count       = var.destination_type == "s3" ? 1 : 0
  name        = local.delivery_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_delivery_role.arn
    bucket_arn          = "arn:aws:s3:::${var.s3_bucket_name}"
    prefix              = var.s3_prefix
    error_output_prefix = var.error_output_prefix
    compression_format  = var.compression_format
    buffering_size      = var.buffer_size
    buffering_interval  = var.buffer_interval

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_s3_log_stream[0].name
    }
  }

  tags = var.tags
}

# Kinesis Firehose Delivery Stream for Snowflake
resource "aws_kinesis_firehose_delivery_stream" "snowflake_delivery_stream" {
  count       = var.destination_type == "snowflake" ? 1 : 0
  name        = local.delivery_stream_name
  destination = "snowflake"

  snowflake_configuration {
    account_url = var.snowflake_account_url
    user        = var.snowflake_username
    database    = var.snowflake_database
    schema      = var.snowflake_schema
    table       = var.snowflake_table
    role_arn    = aws_iam_role.firehose_delivery_role.arn

    # Use the private key directly from Secrets Manager (base64 format)
    private_key = var.snowflake_private_key

    # Optional passphrase for encrypted private keys
    key_passphrase = var.snowflake_private_key_passphrase != "" ? var.snowflake_private_key_passphrase : null

    # Snowflake role configuration
    snowflake_role_configuration {
      enabled        = true
      snowflake_role = var.snowflake_role
    }

    # JSON_MAPPING automatically maps JSON keys to table columns
    data_loading_option = "JSON_MAPPING"

    # Buffering
    buffering_size     = var.buffer_size
    buffering_interval = var.buffer_interval

    # Required S3 backup configuration
    s3_backup_mode = "FailedDataOnly"
    s3_configuration {
      role_arn            = aws_iam_role.firehose_delivery_role.arn
      bucket_arn          = "arn:aws:s3:::${var.s3_bucket_name}"
      prefix              = "snowflake-backup/"
      error_output_prefix = "snowflake-errors/"
      buffering_size      = 5
      buffering_interval  = 300
      compression_format  = "GZIP"

      cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.firehose_log_group.name
        log_stream_name = aws_cloudwatch_log_stream.firehose_snowflake_log_stream[0].name
      }
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_snowflake_log_stream[0].name
    }
  }

  tags = var.tags
}