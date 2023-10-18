
resource "aws_lb" "lb_front" {
  name               = "lb-front"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https_http_security_group.id, aws_security_group.internal_allow_all.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  # enable_deletion_protection = true

  tags = {
    Name = "lb-front"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_lb_target_group" "lb_tg_front" {
  name        = "lb-tg-front-${chomp(file("/etc/hostname"))}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lb-front"
    filter = chomp(file("/etc/hostname"))
  }
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
  tags = {
    Name = "lb-front"
    filter = chomp(file("/etc/hostname"))
  }  
}


resource "aws_lb" "lb_api" {
  name               = "lb-api"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https_http_security_group.id, aws_security_group.internal_allow_all.id, aws_security_group.api_security_group.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  # enable_deletion_protection = true

  tags = {
    Name = "lb-api"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_lb_target_group" "lb_tg_api" {
  name        = "lb-tg-api-${chomp(file("/etc/hostname"))}"
  port        = 3456
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "lb-api"
    filter = chomp(file("/etc/hostname"))
  }  
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
  tags = {
    Name = "lb-api"
    filter = chomp(file("/etc/hostname"))
  }  
}