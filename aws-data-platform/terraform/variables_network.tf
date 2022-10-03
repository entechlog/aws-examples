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
  description = "CIDR block for public Subnet"
  default     = ["172.32.12.0/22"]
}

// Variable to limit ssh ingress to specific CIDR
variable "remote_cidr_block" {
  type    = string
  default = ""
}