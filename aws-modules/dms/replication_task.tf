resource "aws_dms_replication_task" "this" {
  count = var.use_serverless ? 0 : 1

  replication_task_id      = "${local.resource_name_prefix}-replication-${var.source_engine_name}-${var.source_identifier}-to-${var.target_engine_name}-${var.target_identifier}"
  migration_type           = var.migration_type
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn

  # Conditional target endpoint reference based on target type
  target_endpoint_arn      = var.target_engine_name == "s3" ? aws_dms_s3_endpoint.target_s3[0].endpoint_arn : aws_dms_endpoint.target[0].endpoint_arn

  replication_instance_arn = var.replication_instance_arn

  table_mappings           = var.table_mappings
  replication_task_settings = var.replication_task_settings
  start_replication_task         = var.start_replication_task
}