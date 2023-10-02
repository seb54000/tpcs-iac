resource "aws_vpc" "vpc" {
  cidr_block = var.aws_network_cidr

  #### this 2 true values are for use the internal vpc dns resolution
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "${terraform.workspace}-vpc"
    Environment = terraform.workspace
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${terraform.workspace} internet gw terraform generated"
    Environment = terraform.workspace
  }
}

resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${terraform.workspace} Internet"
    Environment = terraform.workspace
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

resource "aws_subnet" "public_subnet" {
  count = 2  # needed for ALB

  cidr_block                      = format("10.1.%s.0/24",count.index) #var.aws_public_subnet_cidr
  vpc_id                          = aws_vpc.vpc.id
  map_public_ip_on_launch         = true

  availability_zone = var.aws_zones[count.index]

  tags = {
    Name        = format("${terraform.workspace}-public-subnet-%s", count.index)
    Environment = terraform.workspace
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block                      = var.aws_private_subnet_cidr
  vpc_id                          = aws_vpc.vpc.id
  map_public_ip_on_launch         = true

  availability_zone = var.aws_zones[0]

  tags = {
    Name        = "${terraform.workspace}-private-subnet"
    Environment = terraform.workspace
  }
}


resource "aws_route_table_association" "public_routing_table" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.internet.id
}
