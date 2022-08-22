# MWAA input variables

variable "env_code" {
  type        = string
  description = "Environment code to identify the target environment(dev,stg,prd)"
  default     = "dev"
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
  type    = list(string)
  default = [""]
}

variable "security_group_id" {
  type    = string
  default = ""
}

variable "mwaa_max_workers" {
  type        = number
  description = "Maximum number of MWAA workers"
  default     = 1
}

variable "mwaa_min_workers" {
  type        = number
  description = "Minimum number of MWAA workers"
  default     = 1
}

variable "mwaa_schedulers" {
  type        = number
  description = "Number of MWAA schedulers"
  default     = 2
}

# airflow.cfg values
# https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-env-variables.html

variable "mwaa_airflow_configuration_options" {
  type        = map(string)
  description = "additional airflow configuration options"
  default     = { "core.lazy_load_plugins" = "False" }
}

# Connections
variable "snowflake_auth_configs" {
  default   = "snowflake://myusername:mypassword@myaccount.us-east-1.snowflakecomputing.com:1234/myschema?account=myaccount&warehouse=mywarehouse&database=mydatabase&region=us-east-1"
  sensitive = true
}