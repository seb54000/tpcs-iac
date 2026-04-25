
resource "aws_security_group" "internal_allow_all" {
  name        = "internal-allow-all"
  description = "Terraform Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  # we allow only IP from private network to input to every port on every protocol
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "${var.aws_public_subnet_cidr_prefix}0.0/24",
      "${var.aws_public_subnet_cidr_prefix}1.0/24",
      "${var.aws_private_subnet_cidr_prefix}0.0/24",
      "${var.aws_private_subnet_cidr_prefix}1.0/24"
    ]
    # To improve (make dynamic), we should declar a network var using cidr function  https://registry.terraform.io/modules/hashicorp/subnets/cidr/1.0.0
  }

  # we allow all machine to output to every port on every protocol on all ips
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "Internal allow all"
    filter = chomp(file("/etc/hostname"))
  }
}


resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "Internal ssh for"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_security_group" "https_http_security_group" {
  name        = "https_http"
  description = "https_http"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "http/https"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_security_group" "api_security_group" {
  name        = "demoboard-api"
  description = "demoboard api"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "TCP"
    cidr_blocks = [
      "${var.aws_public_subnet_cidr_prefix}0.0/24",
      "${var.aws_public_subnet_cidr_prefix}1.0/24",
      "${var.aws_private_subnet_cidr_prefix}0.0/24",
      "${var.aws_private_subnet_cidr_prefix}1.0/24"
    ]
  }
  tags = {
    Name   = "demoboard-api"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_security_group" "postgres_security_group" {
  name        = "demoboard-postgres"
  description = "demoboard postgres"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"
    cidr_blocks = [
      "${var.aws_private_subnet_cidr_prefix}0.0/24",
      "${var.aws_private_subnet_cidr_prefix}1.0/24"
    ]
  }
  tags = {
    Name   = "demoboard-postgres"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_security_group" "redis_security_group" {
  name        = "demoboard-redis"
  description = "demoboard redis"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "TCP"
    cidr_blocks = [
      "${var.aws_private_subnet_cidr_prefix}0.0/24",
      "${var.aws_private_subnet_cidr_prefix}1.0/24"
    ]
  }
  tags = {
    Name   = "demoboard-redis"
    filter = chomp(file("/etc/hostname"))
  }
}
