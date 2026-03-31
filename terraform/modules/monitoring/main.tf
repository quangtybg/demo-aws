resource "aws_cloudwatch_log_group" "eks_cluster" {
  name = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "eks_containers" {
  name = "/aws/containerinsights/${var.cluster_name}/performance"
  retention_in_days = 30
}
