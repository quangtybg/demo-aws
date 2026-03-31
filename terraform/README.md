# Terraform AWS EKS Production Blueprint

This Terraform project provisions a production-grade AWS environment for a microservices platform on EKS with GitHub OIDC-based CI/CD.

Files created

- `terraform/providers.tf`, `terraform/backend.tf`, `terraform/main.tf`, `terraform/variables.tf`, `terraform/outputs.tf`, `terraform/terraform.tfvars.example`
- Modules under `terraform/modules/`: `vpc`, `eks`, `iam`, `ecr`, `rds`, `alb`, `nlb`, `waf`, `cloudfront`, `route53`, `s3`, `monitoring`
- GitHub Actions sample workflow: `terraform/github-workflows/ci-cd.yml`

Pre-reqs

- Terraform >= 1.6
- AWS CLI configured or GitHub OIDC role for CI
- An S3 bucket and DynamoDB table for Terraform remote state (set in `terraform.tfvars`)
- ACM certificate ARN for CloudFront (if using HTTPS)
- Route53 hosted zone already created for `domain_name` in `terraform.tfvars`

Quick start

1. Copy the example tfvars and edit values:

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your account-specific values
```

2. Initialize and plan:

```powershell
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

3. After apply, configure kubectl access locally (example):

```powershell
aws eks update-kubeconfig --name <cluster-name> --region <region>
kubectl get nodes
```

Notes & next steps

- Ensure `backend_bucket` and `backend_dynamodb_table` are created and set in `terraform.tfvars` before `terraform init`.
- Provide `acm_certificate_arn` for CloudFront/ALB if HTTPS is required.
- Add GitHub Secrets for `AWS_ROLE_TO_ASSUME` and `AWS_REGION` and configure the GitHub OIDC trust in the `iam` module outputs.
- This scaffold implements production-oriented defaults: multi-AZ VPC, NAT per AZ, private DB subnets, EKS with managed node group, IRSA patterns, ECR with scanning and lifecycle, Aurora PostgreSQL with KMS, ALB/NLB, WAF, CloudFront, route53 records, and monitoring log groups.

Security

- Least-privilege IAM policies are used where possible. Review the generated policies and tighten ARNs to specific resources when integrating into your account.

Support
If you want, I can:

- Run `terraform init` and `plan` (requires AWS credentials)
- Add Helm charts to install the AWS Load Balancer Controller and configure IRSA bindings
- Add more granular IAM policies scoped to specific ARNs
