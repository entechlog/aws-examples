# -------------------------------------------------------------------------
# EventBridge Rule for triggering DynamoDB export to S3
# -------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "export_dynamodb_to_s3_rule" {
  name                = "${local.resource_name_prefix}-trigger-dynamodb-export"
  description         = "Triggers DynamoDB data export to S3 on a scheduled basis"
  schedule_expression = "rate(1 hour)" // Customize this value as needed for your export frequency
}

# -------------------------------------------------------------------------
# EventBridge Target for invoking the Lambda function
# -------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "export_dynamodb_to_s3_target" {
  arn  = aws_lambda_function.dynamodb_to_s3_export_lambda.arn
  rule = aws_cloudwatch_event_rule.export_dynamodb_to_s3_rule.name
}

# -------------------------------------------------------------------------
# Lambda Permission to allow invocation by CloudWatch Events
# -------------------------------------------------------------------------
resource "aws_lambda_permission" "cloudwatch_invoke_export_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_to_s3_export_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.export_dynamodb_to_s3_rule.arn
}
