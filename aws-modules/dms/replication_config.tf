resource "aws_dms_replication_config" "this" {
  count = var.use_serverless ? 1 : 0

  replication_config_identifier = "${local.resource_name_prefix}-config-${var.source_engine_name}-${var.source_identifier}-to-${var.target_engine_name}-${var.target_identifier}"
  resource_identifier           = "${var.source_engine_name}-to-${var.target_engine_name}-${var.target_identifier}"
  replication_type              = var.replication_type
  source_endpoint_arn           = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn           = aws_dms_s3_endpoint.target_s3[0].endpoint_arn

  table_mappings = var.table_mappings

  start_replication = var.start_replication_task

  compute_config {
    replication_subnet_group_id = var.replication_subnet_group_id
    max_capacity_units          = var.max_capacity_units
    min_capacity_units          = var.min_capacity_units
  }
}
