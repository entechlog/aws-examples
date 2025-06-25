# Unified Datadog Pipeline Module - Supports both S3 and Snowflake destinations

# Local variables
locals {
  common_tags = {
    Project     = "Datadog Integration"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
    EventType   = var.event_name
    Destination = var.destination_type
  }

  # Standardize naming with hyphens
  normalized_event_name = replace(var.event_name, "_", "-")

  # Dynamic table name for Snowflake
  table_name = var.destination_type == "snowflake" ? upper(replace(var.event_name, "-", "_")) : ""

  # S3 prefix for data partitioning
  s3_data_prefix  = "source=datadog/event_name=${local.normalized_event_name}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
  s3_error_prefix = "errors/source=datadog/event_name=${local.normalized_event_name}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

  # Lambda source directory - unique per pipeline to avoid conflicts
  # From module perspective: ../uploads/lambda/ is the source
  # Build directory: ../tmp/lambda-{event}-{destination}/
  lambda_build_dir = "../tmp/lambda-${local.normalized_event_name}-${var.destination_type}"
}

# Create Lambda package directory and copy files
resource "local_file" "lambda_processor" {
  content  = file("../uploads/lambda/datadog_log_processor.py")
  filename = "${local.lambda_build_dir}/datadog_log_processor.py"

  provisioner "local-exec" {
    command = "mkdir -p ${local.lambda_build_dir}"
    when    = create
  }
}

resource "local_file" "lambda_requirements" {
  content  = file("../uploads/lambda/requirements.txt")
  filename = "${local.lambda_build_dir}/requirements.txt"

  depends_on = [local_file.lambda_processor]
}

# Create Lambda deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = local.lambda_build_dir
  output_path = "${local.lambda_build_dir}.zip"

  depends_on = [local_file.lambda_processor, local_file.lambda_requirements]
}

# Kinesis Firehose delivery stream
module "datadog_firehose" {
  source = "../../../../aws-modules/firehose"

  delivery_stream_name = "datadog-${local.normalized_event_name}-to-${var.destination_type}"
  use_env_code         = false
  destination_type     = var.destination_type

  # S3 configuration
  s3_bucket_name      = var.s3_bucket_name
  s3_prefix           = var.destination_type == "snowflake" ? "backup/${local.s3_data_prefix}" : local.s3_data_prefix
  error_output_prefix = var.destination_type == "snowflake" ? "backup/${local.s3_error_prefix}/!{firehose:error-output-type}/" : "${local.s3_error_prefix}/!{firehose:error-output-type}/"

  # Snowflake configuration (only when destination is snowflake)
  snowflake_account_url            = var.destination_type == "snowflake" ? var.snowflake_account_url : ""
  snowflake_username               = var.destination_type == "snowflake" ? var.snowflake_username : ""
  snowflake_database               = var.destination_type == "snowflake" ? var.snowflake_database : ""
  snowflake_schema                 = var.destination_type == "snowflake" ? var.snowflake_schema : ""
  snowflake_table                  = var.destination_type == "snowflake" ? local.table_name : ""
  snowflake_role                   = var.destination_type == "snowflake" ? var.snowflake_role : ""
  snowflake_private_key            = var.destination_type == "snowflake" ? var.snowflake_private_key : ""
  snowflake_private_key_passphrase = var.destination_type == "snowflake" ? var.snowflake_private_key_passphrase : ""

  # Buffer configuration
  buffer_size     = var.buffer_size
  buffer_interval = var.buffer_interval

  tags = local.common_tags
}

# Lambda function using our custom zip file
resource "aws_lambda_function" "datadog_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "datadog-${local.normalized_event_name}-${var.destination_type}-processor"
  role          = aws_iam_role.datadog_lambda_role.arn
  handler       = "datadog_log_processor.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      FIREHOSE_DELIVERY_STREAM = module.datadog_firehose.delivery_stream_name
      DESTINATION_TYPE         = var.destination_type
      EVENT_NAME               = local.normalized_event_name
      TABLE_NAME               = local.table_name
      LOG_FILTERS              = jsonencode(var.datadog_log_filters)
      APPLY_FILTERS            = length(var.datadog_log_filters) > 0 ? "true" : "false"
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/datadog-${local.normalized_event_name}-${var.destination_type}-processor"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# API Gateway for receiving Datadog logs
module "datadog_api_gateway" {
  source = "../../../../aws-modules/api_gateway"

  api_name            = "datadog-${local.normalized_event_name}-${var.destination_type}"
  resource_name       = "${local.normalized_event_name}-${var.destination_type}-logs"
  stage_name          = lower(var.env_code)
  lambda_invoke_arn   = aws_lambda_function.datadog_lambda.invoke_arn
  lambda_function_arn = aws_lambda_function.datadog_lambda.arn

  # Enable API key authentication
  api_key_required = true

  # Throttling and quota
  throttle_rate_limit  = 1000
  throttle_burst_limit = 2000
  quota_limit          = 50000
  quota_period         = "WEEK"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGW-${local.normalized_event_name}-${var.destination_type}-${terraform.workspace}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.datadog_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.datadog_api_gateway.rest_api_execution_arn}/*/*"
}

# IAM role for Lambda
resource "aws_iam_role" "datadog_lambda_role" {
  name = "datadog-lambda-${local.normalized_event_name}-${var.destination_type}-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.datadog_lambda_role.name
}

# IAM policy for Lambda to write to Firehose
resource "aws_iam_role_policy" "lambda_firehose_policy" {
  name = "lambda-firehose-${local.normalized_event_name}-${var.destination_type}-${terraform.workspace}"
  role = aws_iam_role.datadog_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = module.datadog_firehose.delivery_stream_arn
      }
    ]
  })
}

# CloudWatch alarm for monitoring Firehose delivery
resource "aws_cloudwatch_metric_alarm" "firehose_delivery_errors" {
  alarm_name          = "datadog-${local.normalized_event_name}-${var.destination_type}-errors-${terraform.workspace}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = var.destination_type == "snowflake" ? "DeliveryToSnowflake.Records" : "DeliveryToS3.Records"
  namespace           = "AWS/Firehose"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors firehose delivery to ${var.destination_type} for ${local.normalized_event_name}"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DeliveryStreamName = module.datadog_firehose.delivery_stream_name
  }

  tags = local.common_tags
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "datadog-${local.normalized_event_name}-${var.destination_type}-${terraform.workspace}"

  tags = local.common_tags
}

# SNS subscription for email alerts
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}