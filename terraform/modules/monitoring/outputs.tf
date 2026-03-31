output "log_group_cluster" { value = aws_cloudwatch_log_group.eks_cluster.name }
output "log_group_container" { value = aws_cloudwatch_log_group.eks_containers.name }
