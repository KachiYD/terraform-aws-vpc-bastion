resource "aws_lb" "load_balancer" {
    name_prefix = "lb-"
    load_balancer_type = "application"
    subnets = module.vpc.public_subnet_ids
    security_groups = [aws_security_group.app.id]

    enable_deletion_protection = true 
}

resource "aws_lb_target_group" "target" {
  name_prefix = "tg-"
  port = 8000
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
}