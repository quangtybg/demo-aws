locals {
  azs = var.azs
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.name_prefix}-vpc"
    Env  = var.name_prefix
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-igw" }
}

resource "aws_eip" "nat" {
  for_each = { for idx, az in local.azs : az => idx }
  tags = { Name = "${var.name_prefix}-nat-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each = { for idx, az in local.azs : az => idx }
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = { Name = "${var.name_prefix}-nat-${each.key}" }
}

resource "aws_subnet" "public" {
  for_each = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, index(local.azs, each.key))
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = { Name = "${var.name_prefix}-public-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  # Allocate private subnets in non-overlapping /24 ranges after the public range
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, index(local.azs, each.key) + length(local.azs) * 10)
  availability_zone = each.key
  tags = { Name = "${var.name_prefix}-private-${each.key}" }
}

resource "aws_subnet" "db" {
  for_each = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  # Allocate DB subnets in separate /24 ranges further out to avoid overlap
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, index(local.azs, each.key) + length(local.azs) * 20)
  availability_zone = each.key
  tags = { Name = "${var.name_prefix}-db-${each.key}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name_prefix}-rt-public" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[each.key].id
  }
  tags = { Name = "${var.name_prefix}-rt-private-${each.key}" }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = values(aws_subnet.db)[*].id
  tags = { Name = "${var.name_prefix}-db-subnets" }
}

 