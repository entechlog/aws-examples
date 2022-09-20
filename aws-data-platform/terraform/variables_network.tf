variable "private_subnet_id" {
  type    = list(string)
  default = [""]
}

variable "security_group_id" {
  type    = string
  default = ""
}

variable "remote_cidr_block" {
  type    = string
  default = ""
}