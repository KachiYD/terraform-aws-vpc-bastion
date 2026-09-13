data "aws_ami" "ubuntu" {

  most_recent = true
  owners      = ["099720109477"] # Owner is Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_security_group" "app" {
    name_prefix = "private-app-"
    description = "Application traffic in and out of the private app instances"
    vpc_id = aws_vpc.this.id

    tags = {
      Name = "private_app_sg"
    }

    lifecycle {
        create_before_destroy = true
    }  
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  description = "SSH from bastion"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_traffic" {
  security_group_id = aws_security_group.app.id
  description = "Incoming app traffic"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 8000
  to_port = 8000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "name" {
  security_group_id = aws_security_group.app.id
  description = "All outbound"
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_launch_template" "this" {
  name_prefix = "private_app_"
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app.id]

  tag_specifications {
    resource_type = "instance"
    tags          = { 
        Name = "private-app" 
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name = "private_apps_asg"
  vpc_zone_identifier = [ for key, config in local.private_subnets : aws_subnet.this[key].id ]

  min_size = 1
  max_size = 4
  desired_capacity = 2

  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}