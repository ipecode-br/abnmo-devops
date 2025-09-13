# VPC Configuration
resource "aws_vpc" "ipecode_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name     = "${var.project_name}-vpc"
    Projeto  = var.project_name
    Ambiente = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ipecode_igw" {
  vpc_id = aws_vpc.ipecode_vpc.id

  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.ipecode_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-a"
    Type = "public"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.ipecode_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-b"
    Type = "public"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ipecode_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ipecode_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
