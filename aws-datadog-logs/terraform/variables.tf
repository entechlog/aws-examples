# Environment and project configuration
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = false
}

variable "env_code" {
  description = "Environment code"
  type        = string
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email for alerts"
  type        = string
}

# S3 Pipeline Configuration
variable "s3_buffer_size" {
  description = "Firehose buffer size in MB for S3 pipeline"
  type        = number
  default     = 5
}

variable "s3_buffer_interval" {
  description = "Firehose buffer interval in seconds for S3 pipeline"
  type        = number
  default     = 300
}

# Snowflake Pipeline Configuration
variable "snowflake_buffer_size" {
  description = "Firehose buffer size in MB for Snowflake pipeline (larger for cost optimization)"
  type        = number
  default     = 128
}

variable "snowflake_buffer_interval" {
  description = "Firehose buffer interval in seconds for Snowflake pipeline"
  type        = number
  default     = 900
}

# Snowflake configuration
variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
  sensitive   = true
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
  sensitive   = true
}

variable "snowflake_account_url" {
  description = "Snowflake account URL (e.g., https://account.snowflakecomputing.com)"
  type        = string
  sensitive   = true
}

variable "snowflake_username" {
  description = "Snowflake username for Firehose"
  type        = string
}

variable "snowflake_database" {
  description = "Snowflake database name"
  type        = string
}

variable "snowflake_schema" {
  description = "Snowflake schema name"
  type        = string
  default     = "DATADOG"
}

variable "snowflake_role" {
  description = "Snowflake role for Firehose"
  type        = string
}

variable "snowflake_private_key" {
  description = "Snowflake private key for authentication (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "snowflake_private_key_pem" {
  description = "Snowflake private key for authentication (PEM format)"
  type        = string
  sensitive   = true
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for encrypted Snowflake private key (optional - leave empty if key is not encrypted)"
  type        = string
  default     = ""
  sensitive   = true
}