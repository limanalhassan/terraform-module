provider "aws" {
  region = "us-west-1"
}

data "aws_availability_zones" "azs" {}

locals {
  env   = "Dev"
  owner = "Liman.Alhassan"
}

#----------------------------------------------------#
#                  VPC Subnet Settings               #
#----------------------------------------------------#

# Create VPC
resource "aws_vpc" "dev" {
  cidr_block           = var.cidr_block[0]
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env} VPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "${local.env} IGW"
  }
}

#----------------------------------------------------#
#               Public Subnet Settings               #
#----------------------------------------------------#

# Create two public subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.cidr_block[1 + count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.env} public-subnet-${1 + count.index}"
  }
}

# Create a Route Table for public subnets
resource "aws_route_table" "dev_public_route" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "${local.env} Public Route Table"
  }
}

# Create a default route for public subnets via the Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.dev_public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id

}

# Associate the public route table with public subnets
resource "aws_route_table_association" "public_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.dev_public_route.id
}

#----------------------------------------------------#
#               Private Subnet Settings              #
#----------------------------------------------------#

# Create two private subnets
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.cidr_block[3 + count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = {
    Name = "${local.env} private-subnet-${1 + count.index}"
  }
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id # Specify the allocation ID of the Elastic IP for the NAT Gateway
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${local.env} nat-gateway"
  }
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${local.env} EIP"
  }
}

# Create a route table for the private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${local.env} Private Route Table"
  }
}

# Create a route in the private route table to route traffic through the NAT Gateway
resource "aws_route" "private_subnet_route" {
  /* count                  = 2 */
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id

  # Associate this route with the private subnets
  /* depends_on = [aws_subnet.private_subnet[count.index]] */
}

# Associate the private subnets with the private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}



