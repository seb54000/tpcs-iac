resource "aws_key_pair" "keypair" {
  key_name = "sshkey-${terraform.workspace}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQXORyUQjRt6EhrfUieZMZ50YyxSiqDX7j7V5YSzT8Aba05xIrITrL1VEFCMFpia2fqW6T6jdo9AU92Qx+VsSH13EG3XLimuA54XLyfBp77nnVIhZ1FrXVzo4WXITgukMnZ3gVfEvFpcJle3Xc4FxEYuxwXo0EVr6E4KmUk4IuSz8FiiB19svTlBhXpGRvKjnhvfYZuevjoS/RsuChrQ2sqq2xg0FwE4L3l0WQXmd7LMFHxF4WVJr3XvJUfyKEiIC23hrtI43oi11kdQtpFnQRUgAcsG+YRns6ndrfbsZ2IMmlrAa638j6LXs9699l7ibGik20CHdkc3gevxCcLsj28A7qS2PAnJpkXRhgeY7XOqbK4RHTmj0JA6jgfAztyny9H4MKADMsv6RrT5eAEBce2ZcPUrvppFITisEGxhI3fqtQZWKjqXfKsCjtDyw9NXiV6OliV3XE6xHOD16zg9N8ZSCO7+SskSy7eCQbXR1e7KHZEK/kMHDlbItXMMwb0c8= doux@MacBook-Pro-de-Sebastien.local"
}

resource "aws_instance" "front" {
  count = 2

  ami                    = var.ubuntu_ami
  subnet_id              = aws_subnet.public_subnet[count.index].id
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [
                              aws_security_group.internal_allow_all.id,
                              aws_security_group.https_http_security_group.id,
                              aws_security_group.ssh.id
                            ]
  key_name               = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name        = format("front%s-%s", count.index, terraform.workspace)
    Environment = terraform.workspace
    Role        = "front"
  }
}

resource "aws_instance" "api" {
  count = 2

  ami                    = var.ubuntu_ami
  subnet_id              = aws_subnet.private_subnet.id
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [
                              aws_security_group.internal_allow_all.id,
                              aws_security_group.ssh.id
                            ]
  key_name               = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name        = format("api%s-%s", count.index ,terraform.workspace)
    Environment = terraform.workspace
    Role        = "api"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ubuntu_ami
  subnet_id              = aws_subnet.private_subnet.id
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [
                              aws_security_group.internal_allow_all.id,
                              aws_security_group.ssh.id
                            ]
  key_name               = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name        = format("db-%s", terraform.workspace)
    Environment = terraform.workspace
    Role        = "db"
  }
}



resource "aws_lb" "lb_front" {
  name               = "lb-front"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https_http_security_group.id, aws_security_group.internal_allow_all.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  # enable_deletion_protection = true

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_lb_target_group" "lb_tg_front" {
  name        = "lb-tg-front"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "lb_tga_front" {
  count = 2
  target_group_arn = aws_lb_target_group.lb_tg_front.arn
  target_id        = aws_instance.front[count.index].id
  port             = 80
}

resource "aws_lb_listener" "lb_lst_front" {
  load_balancer_arn = aws_lb.lb_front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg_front.arn
  }
}


# TODO : add jumphost to reach through SSH the VMs in private subnets - or use nginx frontend server for that
# TODO add pirvate subnets in differnt zones to host LB private for API
# Put instances API in different zones
# Add a secgroup for vikunja API (port 3456) and also for the LoadBalancer
# API LB should stay in public subnet in order to get the API calls

resource "aws_lb" "lb_api" {
  name               = "lb-api"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https_http_security_group.id, aws_security_group.internal_allow_all.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  # enable_deletion_protection = true

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_lb_target_group" "lb_tg_api" {
  name        = "lb-tg-api"
  port        = 3456
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "lb_tga_api" {
  count = 2
  target_group_arn = aws_lb_target_group.lb_tg_api.arn
  target_id        = aws_instance.api[count.index].id
  port             = 3456
}

resource "aws_lb_listener" "lb_lst_api" {
  load_balancer_arn = aws_lb.lb_api.arn
  port              = "3456"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg_api.arn
  }
}