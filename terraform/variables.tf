variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of AZs to use (3)"
  type        = list(string)
  default     = []
}

variable "public_subnet_bits" {
  description = "Subnet bits for public subnets"
  type        = number
  default     = 24
}

variable "private_subnet_bits" {
  description = "Subnet bits for private subnets"
  type        = number
  default     = 24
}

variable "db_subnet_bits" {
  description = "Subnet bits for DB subnets"
  type        = number
  default     = 24
}

variable "github_oidc_url" {
  description = "GitHub OIDC provider URL for internal GitHub Enterprise"
  type        = string
  default     = "https://github.devops.sec.samsung.net"
}

variable "github_repo" {
  description = "GitHub repo allowed for OIDC (org/repo)"
  type        = string
  default     = "urms-devops"
}

variable "github_branch" {
  description = "GitHub branch reference allowed for OIDC"
  type        = string
  default     = "refs/heads/main"
}

variable "domain_name" {
  description = "DNS domain name for Route53 records"
  type        = string
  default     = "example.internal"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront / ALB"
  type        = string
  default     = ""
}

variable "s3_logging_bucket_name" {
  description = "S3 bucket name for logs"
  type        = string
  default     = ""
}

variable "backend_bucket" {
  description = "S3 bucket for Terraform remote state"
  type        = string
  default     = ""
}

variable "backend_dynamodb_table" {
  description = "DynamoDB table for Terraform state lock"
  type        = string
  default     = ""
}
