variable "env_code" {
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

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = false
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
  default     = "us-east-1"
}

variable "private_subnet_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "ssh_security_group_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}