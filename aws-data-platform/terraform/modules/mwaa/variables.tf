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
  default     = 3
}
