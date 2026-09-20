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

resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnet_ids[0]

  tags = {
    Name = "Bastion Host"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "bastion" {
  key_name_prefix = "bastion-"
  public_key = file(pathexpand(var.public_key_path))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "bastion-"
  description = "Bastion host SSH access"
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "bastion-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  description = "SSH from workstation"
  cidr_ipv4 = var.my_ip_cidr
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  description = "All outbound"
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}