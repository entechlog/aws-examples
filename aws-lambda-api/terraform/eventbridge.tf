# -------------------------------------------------------------------------
# EventBridge Rule for triggering the Lambda function
# -------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "lambda_function" {
  name                = "${local.resource_name_prefix}-trigger-get-pair-candles"
  description         = "Triggers Lambda functionon a scheduled basis"
  schedule_expression = "rate(5 minutes)"
}

# -------------------------------------------------------------------------
# EventBridge Target for invoking the Lambda function
# -------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "export_dynamodb_to_s3_target" {
  arn  = aws_lambda_function.lambda_function.arn
  rule = aws_cloudwatch_event_rule.lambda_function.name

  input = jsonencode({
    "BASE_URL" : "https://community-api.coinmetrics.io/v4/timeseries",
    "ENDPOINT" : "/pair-candles",
    "FREQUENCY" : "1d",
    "PAGE_SIZE" : 1000,
    "S3_BUCKET" : local.target_bucket_name,
    "S3_KEY_PREFIX" : "source=coinmetrics/event_name=pair-candles"
  })

}

# -------------------------------------------------------------------------
# Lambda Permission to allow invocation by CloudWatch Events
# -------------------------------------------------------------------------
resource "aws_lambda_permission" "cloudwatch_invoke_export_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_function.arn
}
