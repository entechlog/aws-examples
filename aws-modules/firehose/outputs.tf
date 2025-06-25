output "delivery_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream"
  value = var.destination_type == "s3" ? (
    length(aws_kinesis_firehose_delivery_stream.s3_delivery_stream) > 0 ?
    aws_kinesis_firehose_delivery_stream.s3_delivery_stream[0].arn : ""
    ) : (
    length(aws_kinesis_firehose_delivery_stream.snowflake_delivery_stream) > 0 ?
    aws_kinesis_firehose_delivery_stream.snowflake_delivery_stream[0].arn : ""
  )
}

output "delivery_stream_name" {
  description = "The name of the Kinesis Firehose delivery stream"
  value = var.destination_type == "s3" ? (
    length(aws_kinesis_firehose_delivery_stream.s3_delivery_stream) > 0 ?
    aws_kinesis_firehose_delivery_stream.s3_delivery_stream[0].name : ""
    ) : (
    length(aws_kinesis_firehose_delivery_stream.snowflake_delivery_stream) > 0 ?
    aws_kinesis_firehose_delivery_stream.snowflake_delivery_stream[0].name : ""
  )
}

output "iam_role_arn" {
  description = "The ARN of the IAM role used by Firehose"
  value       = aws_iam_role.firehose_delivery_role.arn
}

output "destination_type" {
  description = "The destination type of the Firehose delivery stream"
  value       = var.destination_type
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.firehose_log_group.name
}