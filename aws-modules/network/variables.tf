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
  default = "us-east-1"
}

variable "availability_zone" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}

variable "vpc_cidr_block" {
  description = "Specify the vpc CIDR block"
  type        = string
  default     = "172.32.0.0/16"
}

variable "private_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR block for private Subnet"
  default     = ["172.32.0.0/22", "172.32.4.0/22", "172.32.8.0/22"]
}

variable "public_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR block for public Subnet"
  default     = ["172.32.12.0/22", "172.32.16.0/22", "172.32.20.0/22"]
}


variable "remote_cidr_block" {
  description = "IP address of remote network for VPN setup"
  default     = "192.168.0.1/32"
}

variable "create_single_nat_gateway" {
  description = "Whether to create a single NAT gateway or one per public subnet."
  type        = bool
  default     = true
}