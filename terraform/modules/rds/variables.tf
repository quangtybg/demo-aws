variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "kms_key_alias" { type = string }
variable "region" { type = string }
