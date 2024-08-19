# Network

output "data_vpc_vpc_id" {
  value = module.data_vpc.vpc_id
}

output "data_vpc_private_subnets" {
  value = module.data_vpc.private_subnet_id
}

output "data_vpc_public_subnets" {
  value = module.data_vpc.public_subnet_id
}

output "data_vpc_ssh_security_group_id" {
  value = module.data_vpc.ssh_security_group_id
}

# RDS

output "rds_instance_details" {
  description = "Details of the RDS instance"
  value = {
    endpoint            = aws_db_instance.db_instance.endpoint
    db_name             = aws_db_instance.db_instance.db_name
    instance_identifier = aws_db_instance.db_instance.id
    username            = aws_db_instance.db_instance.username
  }
}

# S3

output "s3_details" {
  value = {
    dms_bucket_name = module.dms_s3_bucket.aws_s3_bucket__name[0]
  }
}

# Outputs for Server-Based DMS
output "dms_server_details" {
  value = {
    task_or_config_id = module.dms_replication_server.replication_task_or_config_id
    source_endpoint   = module.dms_replication_server.source_endpoint_arn
    target_endpoint   = module.dms_replication_server.target_endpoint_arn
  }
}

# Outputs for Serverless DMS
output "dms_serverless_details" {
  value = {
    task_or_config_id = module.dms_replication_serverless.replication_task_or_config_id
    source_endpoint   = module.dms_replication_serverless.source_endpoint_arn
    target_endpoint   = module.dms_replication_serverless.target_endpoint_arn
  }
}
