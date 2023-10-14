
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
    Name        = "Internal allow all"
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
    Name        = "Internal ssh for"
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
    Name        = "http/https"
  }
}

resource "aws_security_group" "api_security_group" {
  name        = "api"
  description = "api"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3456
    to_port     = 3456
    protocol    = "TCP"
    cidr_blocks = [
      "${var.aws_public_subnet_cidr_prefix}0.0/24",
      "${var.aws_public_subnet_cidr_prefix}1.0/24",
      "0.0.0.0/0" # Required as External client connects directly to the LB, could be improved 
    ]
  }
  tags = {
    Name        = "api"
  }
}

resource "aws_security_group" "mysql_security_group" {
  name        = "mysql"
  description = "mysql"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = [
      "${var.aws_private_subnet_cidr_prefix}0.0/24",
      "${var.aws_private_subnet_cidr_prefix}1.0/24"
    ]
  }
  tags = {
    Name        = "mysql"
  }
}
