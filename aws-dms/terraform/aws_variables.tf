# Network

variable "vpc_cidr_block" {
  description = "Specify the VPC CIDR block"
  type        = string
  default     = "172.33.0.0/16" # or "10.0.0.0/16" if you prefer
}

variable "private_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR block for private Subnet"
  default     = ["172.33.0.0/22", "172.33.4.0/22", "172.33.8.0/22"] # Adjust accordingly if you choose the "10.0.0.0/16" VPC block
}

variable "public_subnet_cidr_block" {
  type        = list(any)
  description = "CIDR block for public Subnet"
  default     = ["172.33.12.0/22", "172.33.16.0/22", "172.33.20.0/22"] # Adjust accordingly if you choose the "10.0.0.0/16" VPC block
}

// Variable to limit ssh ingress to specific CIDR
variable "remote_cidr_block" {
  type    = string
  default = ""
}

# RDS

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}