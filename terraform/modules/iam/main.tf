resource "aws_iam_openid_connect_provider" "github_actions" {
  url = var.github_oidc_url
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# GitHub Actions role for OIDC -> limited permissions for ECR and EKS deploy
data "aws_iam_policy_document" "github_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*", "repo:${var.github_repo}:ref:${var.github_branch}"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "github_actions_role" {
  name = "${var.name_prefix}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

resource "aws_iam_policy" "github_actions_policy" {
  name = "${var.name_prefix}-github-actions-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
        Effect = "Allow"
      },
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_github_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# IRSA role example for backend pods with S3/SNS/SES access
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backend_pod_role" {
  name = "${var.name_prefix}-backend-pod"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

resource "aws_iam_policy" "backend_pod_policy" {
  name = "${var.name_prefix}-backend-pod-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["s3:PutObject","s3:GetObject","s3:ListBucket"], Resource = "arn:aws:s3:::*" },
      { Effect = "Allow", Action = ["sns:Publish"], Resource = "*" },
      { Effect = "Allow", Action = ["ses:SendEmail","ses:SendRawEmail"], Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backend_policy" {
  role       = aws_iam_role.backend_pod_role.name
  policy_arn = aws_iam_policy.backend_pod_policy.arn
}

 