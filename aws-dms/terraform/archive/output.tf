# DMS

output "dms_details" {
  value = {
    task_name       = aws_dms_replication_task.replication_task.replication_task_id
    source_endpoint = aws_dms_endpoint.rds_source_endpoint.endpoint_id
    target_endpoint = aws_dms_s3_endpoint.s3_target_endpoint.endpoint_id
  }
}
