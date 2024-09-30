# Create the DMS replication instance
resource "aws_dms_replication_instance" "dms_replication_instance" {
  replication_instance_id     = "${local.resource_name_prefix}-dms-replication-instance"
  replication_instance_class  = "dms.t3.micro"
  allocated_storage           = 50
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_private_subnet_group.replication_subnet_group_id
  publicly_accessible         = false
}

# Using the DMS module for server-based replication
module "dms_replication_server" {
  source = "../../aws-modules/dms"

  use_serverless              = false
  replication_instance_arn    = aws_dms_replication_instance.dms_replication_instance.replication_instance_arn
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_private_subnet_group.id

  source_engine_name = "mysql"
  source_username    = "admin"
  source_password    = var.db_password
  source_server_name = aws_db_instance.db_instance.address
  source_port        = 3306
  source_identifier  = "demo-server"

  target_engine_name             = "s3"
  target_service_access_role_arn = aws_iam_role.dms_role.arn
  target_bucket_name             = local.dms_bucket_name
  target_bucket_folder           = "server"
  target_identifier              = "server"

  target_data_format            = "csv" # Change format to Parquet
  target_date_partition_enabled = true
  target_partition_sequence     = "yyyymmdd" # Specify partition sequence

  start_replication_task = true

  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id   = "1"
        rule-name = "1"
        object-locator = {
          schema-name = "demo"
          table-name  = "%"
        }
        rule-action = "include"
      }
    ]
  })
  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetSchema           = ""
      SupportLobs            = true
      FullLobMode            = false
      LobChunkSize           = 0
      LimitedSizeLobMode     = true
      LobMaxSize             = 32
      InlineLobMaxSize       = 0
      LoadMaxFileSize        = 0
      ParallelLoadBufferSize = 0
      BatchApplyEnabled      = false
    }
    Logging = {
      EnableLogging = true
    }
  })
}

# Outputs for Server-Based DMS
output "dms_server_details" {
  value = {
    task_or_config_id = module.dms_replication_server.replication_task_or_config_id
    source_endpoint   = module.dms_replication_server.source_endpoint_arn
    target_endpoint   = module.dms_replication_server.target_endpoint_arn
  }
}