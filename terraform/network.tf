##############################################################
##VPC
##############################################################
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  enable_classiclink_dns_support = false
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "main"
  }
}


##############################################################
##INTERNET GATEWAY
##############################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


##############################################################
##ELASTIC IP
##############################################################
resource "aws_eip" "elast_ip_nat_1" {
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "elast_ip_nat_2" {
  depends_on = [aws_internet_gateway.main]
}


##############################################################
##SUBNETS
##############################################################
resource "aws_subnet" "subnet_publica_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.0.0/18"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name                        = "public-us-east-1a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "subnet_publica_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.64.0/18"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                        = "public-us-east-1b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "subnet_privada_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.128.0/18"
  availability_zone = "us-east-1a"

  tags = {
    Name                              = "private-us-east-1a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "subnet_privada_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.192.0/18"
  availability_zone = "us-east-1b"

  tags = {
    Name                              = "private-us-east-1b"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}


##############################################################
##NAT GATEWAY
##############################################################
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.elast_ip_nat_1.id
  subnet_id = aws_subnet.subnet_publica_1.id

  tags = {
    Name = "NAT 1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.elast_ip_nat_2.id
  subnet_id = aws_subnet.subnet_publica_2.id

  tags = {
    Name = "NAT 2"
  }
}


##############################################################
##ROUTE TABLE
##############################################################
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "privada_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  tags = {
    Name = "private1"
  }
}

resource "aws_route_table" "privada_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  tags = {
    Name = "private2"
  }
}


##############################################################
##ROUTE TABLE ASSOCIATION
##############################################################
resource "aws_route_table_association" "publica_1" {
  subnet_id = aws_subnet.subnet_publica_1.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "publica_2" {
  subnet_id = aws_subnet.subnet_publica_2.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "privada_1" {
  subnet_id = aws_subnet.subnet_privada_1.id
  route_table_id = aws_route_table.privada_1.id
}

resource "aws_route_table_association" "privada_2" {
  subnet_id = aws_subnet.subnet_privada_2.id
  route_table_id = aws_route_table.privada_2.id
}



##############################################################
##OUTPUT 
##############################################################
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC id."
  sensitive = false
}


