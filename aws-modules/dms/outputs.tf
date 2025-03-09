# Output for replication task or config ID based on `use_serverless` flag
output "replication_task_or_config_id" {
  value       = var.use_serverless ? aws_dms_replication_config.this[0].replication_config_identifier : aws_dms_replication_task.this[0].replication_task_id
  description = "The ID of the DMS replication task or the identifier of the DMS replication config (serverless)."
}

# Output for source endpoint ARN (assuming no count or for_each)
output "source_endpoint_arn" {
  value       = aws_dms_endpoint.source.endpoint_arn
  description = "The ARN of the source endpoint."
}

# Output for target endpoint ARN based on target type
output "target_endpoint_arn" {
  value       = var.target_engine_name == "s3" ? aws_dms_s3_endpoint.target_s3[0].endpoint_arn : aws_dms_endpoint.target[0].endpoint_arn
  description = "The ARN of the target endpoint, dynamically chosen based on the target type (S3 or another database)."
}
