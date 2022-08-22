variable "env_code" {
  default = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
  default     = "us-east-1"
}

variable "private_subnet_id" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "kafka_version" {
  default = "3.2.0"
}

variable "brokers_count" {
  default = 3
}

variable "broker_instance_type" {
  default = "kafka.t3.small"
}

variable "broker_ebs_volume_size" {
  default = 100
}

variable "kafka_unauthenticated_access_enabled" {
  default = true
}

variable "kafka_sasl_scram_auth_enabled" {
  default = true
}

variable "kafka_sasl_iam_auth_enabled" {
  default = true
}

variable "kafka_sasl_scram_auth_configs" {
  default = {
    username = "foo",
    password = "uswgbhdaubhdaiubhdhauvdea"
  }
  sensitive = true
}

variable "open_monitoring" {
  default = true
}

variable "kafka_connect_version" {
  default = "2.7.1"
}

// MongoDB
variable "mongodbdb_uri" {
  description = "MongoDB database uri"
  type        = string
}

variable "mongodb_username" {
  description = "MongoDB database username"
  type        = string
  sensitive   = true
}

variable "mongodbdb_password" {
  description = "MongoDB database password"
  type        = string
  sensitive   = true
}

variable "mongodb_vpce_service_name" {
  description = "MongoDB Atlas Endpoint Service	Name"
  type        = string
  sensitive   = true
}

// Snowflake
variable "snowflake_url_name" {
  description = "Snowflake database uri"
  type        = string
}

variable "snowflake_user_name" {
  description = "Snowflake database username"
  type        = string
  sensitive   = true
}

variable "snowflake_private_key" {
  description = "Snowflake private key"
  type        = string
  sensitive   = true
}

variable "snowflake_private_key_passphrase" {
  description = "Snowflake private key passphrase"
  type        = string
  sensitive   = true
}