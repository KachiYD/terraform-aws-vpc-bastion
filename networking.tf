module "vpc" {
  source = "./modules/networking"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "Main VPC"
  }

  subnet_config = {
    public_sub_1 = {
      cidr_block = "10.0.0.0/24"
      az         = "ca-central-1a"
      public     = true
    }
    public_sub_2 = {
      cidr_block = "10.0.1.0/24"
      az         = "ca-central-1b"
      public     = true
    }
    private_sub_1 = {
      cidr_block = "10.0.2.0/24"
      az         = "ca-central-1a"
    }
    private_sub_2 = {
      cidr_block = "10.0.3.0/24"
      az         = "ca-central-1b"
    }
  }
}