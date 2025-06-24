# Required variables
variable "event_name" {
  description = "Name of the event type (e.g., user-events, system-events)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.event_name))
    error_message = "Event name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "destination_type" {
  description = "Destination type: 's3' or 'snowflake'"
  type        = string
  validation {
    condition     = contains(["s3", "snowflake"], var.destination_type)
    error_message = "Destination type must be either 's3' or 'snowflake'."
  }
}

variable "env_code" {
  description = "Environment code"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "alert_email" {
  description = "Email for alerts"
  type        = string
}

# S3 bucket configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for storing logs (will be created if create_bucket is true)"
  type        = string
  default     = ""
}

# Buffer configuration
variable "buffer_size" {
  description = "Firehose buffer size in MB"
  type        = number
  default     = 5
}

variable "buffer_interval" {
  description = "Firehose buffer interval in seconds"
  type        = number
  default     = 300
}

# Datadog log filters (optional)
variable "datadog_log_filters" {
  description = "Datadog log filters for this event type (optional - filtering should be done at Datadog level)"
  type        = list(string)
  default     = []
}

# Snowflake configuration (only required when destination_type = "snowflake")
variable "snowflake_account_url" {
  description = "Snowflake account URL"
  type        = string
  default     = ""
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
  default     = ""
}

variable "snowflake_database" {
  description = "Snowflake database name"
  type        = string
  default     = ""
}

variable "snowflake_schema" {
  description = "Snowflake schema name"
  type        = string
  default     = "DATADOG"
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = ""
}

variable "snowflake_private_key" {
  description = "Snowflake private key for authentication (base64 format - use the script output)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for encrypted Snowflake private key (optional - leave empty if key is not encrypted)"
  type        = string
  default     = ""
  sensitive   = true
}