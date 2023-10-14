resource "aws_vpc" "vpc" {
  cidr_block = var.aws_network_cidr

  #### this 2 true values are for use the internal vpc dns resolution
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name        = "tpiac-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "internet gw terraform generated"
  }
}

resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "Internet"
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
  count = 2  # needed for ALB, at least 2 subents to balance traffic

  cidr_block                      = format("%s%s.0/24",var.aws_public_subnet_cidr_prefix, count.index)
  vpc_id                          = aws_vpc.vpc.id
  map_public_ip_on_launch         = true

  availability_zone = var.aws_zones[count.index]

  tags = {
    Name        = format("tpiac-public-subnet-%s", count.index)
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  cidr_block                      = format("%s%s.0/24",var.aws_private_subnet_cidr_prefix, count.index)
  vpc_id                          = aws_vpc.vpc.id
  map_public_ip_on_launch         = false

  availability_zone = var.aws_zones[count.index]

  tags = {
    Name        = "tpiac-private-subnet-${count.index}"
  }
}


resource "aws_route_table_association" "public_routing_table" {
  count = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.internet.id
}


resource "aws_eip" "nat_gateway" {
  count = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  count = 2
  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "nat_gateway" {
  count = 2  
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "nat_gateway ${count.index}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  # route {
  #   ipv6_cidr_block = "::/0"
  #   gateway_id      = aws_nat_gateway.nat_gw[count.index].id
  # }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}


resource "aws_route_table_association" "nat_gateway_routing_table" {
  count = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.nat_gateway[count.index].id
}
