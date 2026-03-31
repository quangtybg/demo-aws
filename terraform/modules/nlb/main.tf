
resource "aws_lb" "nlb" {
  name               = var.name
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags = { Name = var.name }
}

