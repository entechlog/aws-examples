//* VPC

variable "env_code" {
  default = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  default = "us-east-1"
}

