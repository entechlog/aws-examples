# Using the DMS module for serverless replication
module "dms_replication_serverless" {
  source = "../../aws-modules/dms"

  use_serverless              = true
  replication_instance_arn    = ""
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_private_subnet_group.id
  source_engine_name          = "mysql"
  source_username             = "admin"
  source_password             = var.db_password
  source_server_name          = aws_db_instance.db_instance.address
  source_port                 = 3306
  source_identifier           = "demo-serverless"

  target_engine_name             = "s3"
  target_service_access_role_arn = aws_iam_role.dms_role.arn
  target_bucket_name             = local.dms_bucket_name
  target_bucket_folder           = "serverless"
  target_identifier              = "serverless"

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

# Outputs for Serverless DMS
output "dms_serverless_details" {
  value = {
    task_or_config_id = module.dms_replication_serverless.replication_task_or_config_id
    source_endpoint   = module.dms_replication_serverless.source_endpoint_arn
    target_endpoint   = module.dms_replication_serverless.target_endpoint_arn
  }
}
