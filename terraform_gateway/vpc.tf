# main  vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name = "vpc-development"
  }
}

// Public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  tags = {
    Name = "PublicSubnet01"

  }
}



// Private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-2a"
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0)

  tags = {
    Name = "PrivateSubnet01"
  }
}



//IGW + NAT GW
resource "aws_eip" "eip_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gw"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_nat_gateway.nat_gateway_1, aws_subnet.public_subnet_1, aws_internet_gateway.internet_gateway]

  tags = {
    Name = "NatGatewayAZ1"
  }
}


//Route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  #lifecycle {
  #  ignore_changes = [
  #    route
  #  ]
  #}

  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name    = "Public Subnets"
    Network = "Public"
  }
}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  depends_on = [aws_internet_gateway.internet_gateway, aws_nat_gateway.nat_gateway_1]

  tags = {
    Name    = "Private Subnet AZ1"
    Network = "Private01"
  }
}


// Associations:
resource "aws_main_route_table_association" "public_subnet_1_main_route_table_association" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}



resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.public_subnet_1.id]

    # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

    # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

tags = {
    Name = "My VPC ACL"
}
} 