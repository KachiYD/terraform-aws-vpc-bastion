resource "aws_lb" "load_balancer" {
    name_prefix = "lb-"
    load_balancer_type = "application"
    subnets = module.vpc.public_subnet_ids
    security_groups = [aws_security_group.app.id]

    #enable_deletion_protection = true 
}

resource "aws_lb_target_group" "target" {
  name_prefix = "tg-"
  port = 8000
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}