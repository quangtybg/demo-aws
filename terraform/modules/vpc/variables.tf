variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_bits" { type = number }
variable "private_subnet_bits" { type = number }
variable "db_subnet_bits" { type = number }
variable "name_prefix" { type = string }
