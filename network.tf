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
# Internet Gateway
# ==================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.app_name}-igw"
  }
}

# ==================================================
# Elastic IP (for NAT Gateway)
# ==================================================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${local.app_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==================================================
# NAT Gateway (for Protected Subnet)
# ==================================================
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.alb[0].id

  tags = {
    Name = "${local.app_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==================================================
# Public Subnet (for ALB)
# ==================================================
resource "aws_subnet" "alb" {
  count                   = length(var.alb_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.alb_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.app_name}-public-subnet-${substr(local.azs[count.index % length(local.azs)], -2, -1)}"
    Type = "Public"
  }
}

# ==================================================
# Protected Subnet (for ECS)
# ==================================================
resource "aws_subnet" "protected" {
  count             = length(var.protected_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.protected_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index % length(local.azs)]

  tags = {
    Name = "${local.app_name}-protected-subnet-${substr(local.azs[count.index % length(local.azs)], -2, -1)}"
    Type = "Protected"
  }
}

# ==================================================
# Private Subnet (for RDS)
# ==================================================
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index % length(local.azs)]

  tags = {
    Name = "${local.app_name}-private-subnet-${substr(local.azs[count.index % length(local.azs)], -2, -1)}"
    Type = "Private"
  }
}

# ==================================================
# Route Table (Public) & Association
# ==================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
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
# Route Table (Protected) & Association
# ==================================================
resource "aws_route_table" "protected" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${local.app_name}-protected-rt"
  }
}

resource "aws_route_table_association" "protected" {
  count          = length(aws_subnet.protected)
  subnet_id      = aws_subnet.protected[count.index].id
  route_table_id = aws_route_table.protected.id
}

# ==================================================
# Route Table (Private) & Association
# ==================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.app_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
