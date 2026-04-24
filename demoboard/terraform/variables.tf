
variable "aws_network_cidr" {
  default = "0.0.0.0/0"
}

variable "aws_public_subnet_cidr_prefix" {
  type = string
}

variable "aws_private_subnet_cidr_prefix" {
  type = string
}

variable "demoboard_aws_zones" {
  type    = list(string)
  default = ["eu-west-3a", "eu-west-3b"]
}

variable "ubuntu_ami" {
  default = "ami-0ec59e7bad062131f"
}

variable "ssh_key_public" {
  type = string
}
