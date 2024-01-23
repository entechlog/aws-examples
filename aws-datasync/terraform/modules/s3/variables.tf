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

variable "aws_region" {
  default = "us-east-1"
}

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = false
}

variable "s3_bucket_name" {
  default = "demo"
}