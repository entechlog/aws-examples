# Define the DMS replication subnet group
resource "aws_dms_replication_subnet_group" "dms_private_subnet_group" {
  replication_subnet_group_description = "Private subnet group for DMS replication"
  replication_subnet_group_id          = "${local.resource_name_prefix}-dms-replication-subnet-group"
  subnet_ids                           = module.data_vpc.private_subnet_id
}

# Create the DMS replication instance, using the correct DMS subnet group
resource "aws_dms_replication_instance" "dms_replication_instance" {
  replication_instance_id     = "${local.resource_name_prefix}-dms-replication-instance"
  replication_instance_class  = "dms.t3.micro"
  allocated_storage           = 50
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_private_subnet_group.replication_subnet_group_id
  publicly_accessible         = false
}

# Define the source endpoint for the DMS task, pointing to the RDS instance
resource "aws_dms_endpoint" "rds_source_endpoint" {
  endpoint_id   = "${local.resource_name_prefix}-rds-source-endpoint"
  endpoint_type = "source"
  engine_name   = "mysql"
  username      = "admin"
  password      = var.db_password
  server_name   = aws_db_instance.db_instance.address
  port          = 3306
}

# Define the target endpoint for the DMS task, pointing to the S3 bucket
resource "aws_dms_s3_endpoint" "s3_target_endpoint" {
  endpoint_id             = "${local.resource_name_prefix}-s3-target-endpoint"
  endpoint_type           = "target"
  bucket_name             = local.dms_bucket_name
  service_access_role_arn = aws_iam_role.dms_role.arn
}


# Create the DMS replication task to replicate data from RDS to S3
resource "aws_dms_replication_task" "replication_task" {
  replication_task_id      = "${local.resource_name_prefix}-rds-to-s3-replication-task"
  migration_type           = "full-load-and-cdc"
  cdc_start_time           = "1993-05-21T05:50:00Z"
  source_endpoint_arn      = aws_dms_endpoint.rds_source_endpoint.endpoint_arn
  target_endpoint_arn      = aws_dms_s3_endpoint.s3_target_endpoint.endpoint_arn
  replication_instance_arn = aws_dms_replication_instance.dms_replication_instance.replication_instance_arn

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
      },
    ]
  })

  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetSchema       = ""
      SupportLobs        = true
      FullLobMode        = false
      LobChunkSize       = 0
      LimitedSizeLobMode = true
      LobMaxSize         = 32
      InlineLobMaxSize   = 0
      LoadMaxFileSize    = 0
      # Removed ParallelLoadThreads as it's unavailable for S3 targets
      ParallelLoadBufferSize = 0
      BatchApplyEnabled      = false
    }
    Logging = {
      EnableLogging = true
    }
  })
}

# Serverless DMS Replication Configuration
resource "aws_dms_replication_config" "dms_replication_config" {
  replication_config_identifier = "${local.resource_name_prefix}-dms-replication-config"
  resource_identifier           = "${local.resource_name_prefix}-dms-resource"
  replication_type              = "full-load-and-cdc"
  source_endpoint_arn           = aws_dms_endpoint.rds_source_endpoint.endpoint_arn
  target_endpoint_arn           = aws_dms_s3_endpoint.s3_target_endpoint.endpoint_arn
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

  start_replication = true

  compute_config {
    replication_subnet_group_id = aws_dms_replication_subnet_group.dms_private_subnet_group.replication_subnet_group_id
    max_capacity_units          = "2"
    min_capacity_units          = "1"
  }
}
