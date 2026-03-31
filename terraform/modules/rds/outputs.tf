output "cluster_endpoint" { value = aws_rds_cluster.aurora.endpoint }
output "master_password" { value = random_password.db.result }
