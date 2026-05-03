# ==================================================
# VPC
# ==================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.app_name}-vpc"
  }
}

# ==================================================
# インターネットゲートウェイ
# ==================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.app_name}-igw"
  }
}

# ==================================================
# Elastic IP（NAT Gateway用）
# ==================================================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${local.app_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==================================================
# NAT Gateway（プライベートサブネット用）
# ==================================================
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.alb[0].id  # パブリックサブネット

  tags = {
    Name = "${local.app_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==================================================
# パブリックサブネット（ALB用）
# ==================================================
resource "aws_subnet" "alb" {
  count                   = length(var.alb_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.alb_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.app_name}-alb-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# ==================================================
# プライベートサブネット（ECS用）
# ==================================================
resource "aws_subnet" "api" {
  count             = length(var.api_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.api_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index % length(local.azs)]

  tags = {
    Name = "${local.app_name}-api-subnet-${count.index + 1}"
    Type = "Private"
  }
}

# ==================================================
# ルートテーブル（パブリック）
# ==================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.app_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.alb)
  subnet_id      = aws_subnet.alb[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==================================================
# ルートテーブル（プライベート）
# ==================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${local.app_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.api)
  subnet_id      = aws_subnet.api[count.index].id
  route_table_id = aws_route_table.private.id
}
