variable "my_ip_cidr" {
  description = "Your workstation's public IP in CIDR form"
  type = string
}

variable "public_key_path" {
  description = "Path to the SSH public key for the bastion"
  type = string
  default = "~/.ssh/tf-bastion.pub"
}