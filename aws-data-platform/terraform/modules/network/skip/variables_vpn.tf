variable "remote_public_ip_address" {
  description = "IP address of remote network for VPN setup"
  default     = "66.183.124.7"
}

variable "remote_private_cidr_block" {
  description = "CIDR block of remote network for VPN setup"
  default     = "192.168.0.0/24"
}