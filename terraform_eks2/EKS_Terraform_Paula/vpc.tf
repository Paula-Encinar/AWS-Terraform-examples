resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.64.0/18"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                      = "public-eu-west-2b"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/eks" = "shared"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.128.0/18"
  availability_zone = "eu-west-2a"

  tags = {
    "Name"                            = "private-eu-west-2a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks"       = "shared"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.192.0/18"
  availability_zone = "eu-west-2b"

  tags = {
    "Name"                            = "private-eu-west-2b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks"       = "shared"
  }
}

resource "aws_internet_gateway" "main" {
  #The VPC ID to create in.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_eip" "nat1" {

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "gw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "NAT1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw1.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "public" {

  subnet_id = aws_subnet.public_2.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {

  subnet_id = aws_subnet.private_1.id

  route_table_id = aws_route_table.private.id
}