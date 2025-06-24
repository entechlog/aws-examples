variable "delivery_stream_name" {
  description = "Name of the Kinesis Firehose delivery stream"
  type        = string
}

variable "use_env_code" {
  description = "Whether to append environment code to resource names"
  type        = bool
  default     = false
}

# Destination type
variable "destination_type" {
  description = "Destination type: 's3' or 'snowflake'"
  type        = string
  default     = "s3"
  validation {
    condition     = contains(["s3", "snowflake"], var.destination_type)
    error_message = "Destination type must be either 's3' or 'snowflake'."
  }
}

# S3 Configuration (used for both S3 destination and Snowflake backup)
variable "s3_bucket_name" {
  description = "Name of the destination S3 bucket (or backup bucket for Snowflake)"
  type        = string
  # Note: This is required for both S3 and Snowflake destinations
}

variable "s3_prefix" {
  description = "S3 prefix for delivered objects"
  type        = string
  default     = "logs/"
}

variable "error_output_prefix" {
  description = "S3 prefix for error output"
  type        = string
  default     = "errors/"
}

variable "compression_format" {
  description = "Compression format"
  type        = string
  default     = "GZIP"
}

# Snowflake Configuration
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
  default     = "PUBLIC"
}

variable "snowflake_table" {
  description = "Snowflake table name"
  type        = string
  default     = ""
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  type        = string
  default     = ""
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = "ACCOUNTADMIN"
}

variable "snowflake_private_key" {
  description = "Snowflake private key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "snowflake_private_key_passphrase" {
  description = "Passphrase for encrypted Snowflake private key (leave empty for unencrypted keys)"
  type        = string
  default     = ""
  sensitive   = true
}

# Buffer Configuration
variable "buffer_size" {
  description = "Buffer size in MB (1-128)"
  type        = number
  default     = 5
}

variable "buffer_interval" {
  description = "Buffer interval in seconds (60-900)"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}