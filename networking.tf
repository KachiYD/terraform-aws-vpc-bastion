module "vpc" {
  source = "./modules/networking"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "Main VPC"
  }

  subnet_config = {
    public_sub_1 = {
        cidr_block = "10.0.0.0/24"
        az = "ca-central-1a"
        public = true
    }
  }
}