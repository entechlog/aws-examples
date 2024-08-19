variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
  default     = "us-east-1"
}

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

variable "app_code" {
  type        = string
  description = "App code which will be used as prefix when naming resources"
  default     = "data"
}

variable "use_env_code" {
  description = "Toggle on/off the env code in the resource names"
  type        = bool
  default     = false
}