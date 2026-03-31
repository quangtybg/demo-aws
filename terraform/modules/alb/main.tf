resource "aws_lb" "alb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = []
  subnets            = var.public_subnet_ids
  enable_deletion_protection = true
  tags = { Name = var.name }
}


