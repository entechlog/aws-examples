// Update the templates to use these variables instead of 
// module.*.variable_name when working with an existing network

variable "private_subnet_id" {
  type    = list(string)
  default = [""]
}

variable "public_subnet_id" {
  type    = list(string)
  default = [""]
}

variable "kafka_security_group_id" {
  type    = string
  default = ""
}

variable "ssh_security_group_id" {
  type    = string
  default = ""
}
