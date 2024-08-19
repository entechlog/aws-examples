# Naming convention variables
variable "env_code" {
  type    = string
  default = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "app_code" {
  type        = string
  description = "Application code which will be used as prefix when naming resources"
  default     = "data"
}

variable "use_env_code" {
  type        = bool
  description = "Toggle on/off the env code in the resource names"
  default     = false
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
  default     = "us-east-1"
}

# DMS variables

variable "use_serverless" {
  description = "Whether to use DMS serverless or a traditional server-based instance."
  type        = bool
  default     = false
}

variable "replication_type" {
  description = "Type of replication (e.g., full-load, cdc, full-load-and-cdc)."
  type        = string
  default     = "full-load-and-cdc"
}

variable "replication_instance_arn" {
  description = "The ARN of the DMS replication instance."
  type        = string
}

variable "replication_subnet_group_id" {
  description = "The ID of the DMS replication subnet group."
  type        = string
}

variable "start_replication_task" {
  description = "Flag to determine whether the replication task should start automatically."
  type        = bool
  default     = true
}

variable "source_engine_name" {
  description = "Engine name for the source endpoint."
  type        = string
  default     = "mysql"
}

variable "source_server_name" {
  description = "Server name (address) of the source database."
  type        = string
}

variable "source_port" {
  description = "Port number for the source database."
  type        = number
  default     = 3306
}

variable "source_username" {
  description = "Username for the source database."
  type        = string
}

variable "source_password" {
  description = "Password for the source database."
  type        = string
}

variable "target_engine_name" {
  description = "Engine name for the target endpoint."
  type        = string
}

variable "target_server_name" {
  description = "Server name (address) of the target database."
  type        = string
  default     = ""
}

variable "target_port" {
  description = "Port number for the target database."
  type        = number
  default     = 0
}

variable "target_username" {
  description = "Username for the target database."
  type        = string
  default     = ""
}

variable "target_password" {
  description = "Password for the target database."
  type        = string
  default     = ""
}

variable "target_service_access_role_arn" {
  description = "ARN of the IAM role for accessing the target service."
  type        = string
}

variable "target_bucket_name" {
  description = "Name of the S3 bucket for the target endpoint."
  type        = string
}

variable "target_bucket_folder" {
  description = "Name of the S3 bucket folder for the target endpoint."
  type        = string
}

variable "table_mappings" {
  description = "Table mappings in JSON format for the replication task."
  type        = string
}

variable "replication_task_settings" {
  description = "Replication task settings in JSON format."
  type        = string
}

variable "migration_type" {
  description = "Type of replication (e.g., full-load, cdc, full-load-and-cdc)."
  type        = string
  default     = "full-load-and-cdc"
}

variable "max_capacity_units" {
  description = "Maximum capacity units for serverless DMS."
  type        = string
  default     = "2"
}

variable "min_capacity_units" {
  description = "Minimum capacity units for serverless DMS."
  type        = string
  default     = "1"
}

variable "source_identifier" {
  description = "An additional identifier to distinguish the source endpoint."
  type        = string
}

variable "target_identifier" {
  description = "An additional identifier to distinguish the target endpoint."
  type        = string
}

variable "target_data_format" {
  description = "The data format for the target (e.g., csv, json, parquet)."
  type        = string
  default     = "csv"
}

variable "target_date_partition_enabled" {
  description = "Enable or disable date partitioning for the target."
  type        = bool
  default     = true
}

variable "target_partition_sequence" {
  description = "The sequence for date partitioning (e.g., yyyymmddhh)."
  type        = string
  default     = "yyyymmddhh"
}
