module "vpc" {
  source = "./modules/networking"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "Main VPC"
  }
}