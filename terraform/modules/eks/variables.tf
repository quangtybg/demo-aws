variable "cluster_name" { type = string }
variable "region" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "node_group_desired_capacity" { type = number }
variable "node_group_min_capacity" { type = number }
variable "node_group_max_capacity" { type = number }
variable "name_prefix" { type = string }
variable "github_actions_role_arn" { type = string }
variable "ami_type" {
	type    = string
	default = "AL2023_x86_64_STANDARD"
}
