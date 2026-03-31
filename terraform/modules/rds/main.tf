resource "aws_kms_key" "rds" {
  description = "KMS key for RDS encryption"
  deletion_window_in_days = 30
  tags = { Name = "${var.name_prefix}-rds-kms" }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.name_prefix}-aurora"
  engine             = "aurora-postgresql"
  master_username    = "aurora_admin"
  master_password    = random_password.db.result
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  storage_encrypted  = true
  kms_key_id         = aws_kms_key.rds.arn
  db_subnet_group_name = aws_db_subnet_group.this.id
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_rds_cluster_instance" "instances" {
  count              = 2
  identifier         = "${var.name_prefix}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.aurora.engine
  publicly_accessible = false
  performance_insights_enabled = true
}


resource "random_password" "db" {
  length  = 16
  special = true
}

