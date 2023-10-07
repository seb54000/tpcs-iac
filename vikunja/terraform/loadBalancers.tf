
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
  security_groups    = [aws_security_group.https_http_security_group.id, aws_security_group.internal_allow_all.id, aws_security_group.api_security_group.id]
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