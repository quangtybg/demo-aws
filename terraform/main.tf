locals {
  name_prefix = "${var.environment}-demo"
}

module "vpc" {
  source      = "./modules/vpc"
  region      = var.region
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
  public_subnet_bits  = var.public_subnet_bits
  private_subnet_bits = var.private_subnet_bits
  db_subnet_bits      = var.db_subnet_bits
  name_prefix = local.name_prefix
}

# module "s3_logging" {
#   source = "./modules/s3"
#   name   = "${local.name_prefix}-logs"
#   bucket = var.s3_logging_bucket_name
# }

# module "ecr" {
#   source = "./modules/ecr"
#   name   = "${local.name_prefix}-app"
# }

module "iam" {
  source          = "./modules/iam"
  github_oidc_url = var.github_oidc_url
  github_repo     = var.github_repo
  github_branch   = var.github_branch
  region          = var.region
  name_prefix     = local.name_prefix
}

module "eks" {
  source      = "./modules/eks"
  cluster_name = "${local.name_prefix}-eks"
  region      = var.region
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  public_subnet_ids = module.vpc.public_subnets
  node_group_desired_capacity = 2
  node_group_max_capacity = 4
  node_group_min_capacity = 2
  name_prefix = local.name_prefix
  github_actions_role_arn = module.iam.github_actions_role_arn
}

# module "rds" {
#   source      = "./modules/rds"
#   name_prefix = local.name_prefix
#   vpc_id      = module.vpc.vpc_id
#   db_subnet_ids = module.vpc.db_subnets
#   kms_key_alias = "alias/${local.name_prefix}-rds"
#   region = var.region
# }

# module "alb" {
#   source = "./modules/alb"
#   name   = "${local.name_prefix}-alb"
#   vpc_id = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnets
# }

# module "nlb" {
#   source = "./modules/nlb"
#   name   = "${local.name_prefix}-nlb"
#   subnet_ids = module.vpc.public_subnets
# }

# module "route53" {
#   source = "./modules/route53"
#   domain = var.domain_name
#   alb_arn = module.alb.alb_arn
#   nlb_dns = module.nlb.nlb_dns_name
# }

# module "waf" {
#   source = "./modules/waf"
#   name   = "${local.name_prefix}-waf"
#   region = var.region
#   alb_arn = module.alb.alb_arn
# }

# module "cloudfront" {
#   source = "./modules/cloudfront"
#   name = "${local.name_prefix}-cf"
#   alb_dns = module.alb.alb_dns_name
#   acm_certificate_arn = var.acm_certificate_arn
#   logging_bucket = module.s3_logging.bucket_id
# }

# module "monitoring" {
#   source = "./modules/monitoring"
#   cluster_name = module.eks.cluster_name
#   region = var.region
# }

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

locals {
  aws_auth_map_roles = concat(
    [
      {
        rolearn  = module.eks.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers","system:nodes"]
      }
    ],
    length(module.iam.github_actions_role_arn) > 0 ? [
      {
        rolearn  = module.iam.github_actions_role_arn
        username = "github-actions"
        groups   = ["system:masters"]
      }
    ] : []
  )
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.aws_auth_map_roles)
  }

  depends_on = [module.eks]
}
