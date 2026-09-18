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