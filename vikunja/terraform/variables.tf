variable "aws_region" {
  default = "eu-west-3"
}

variable "aws_network_cidr" {
  default = "0.0.0.0/0"
}
variable "aws_public_subnet_cidr" {
  default = "0.0.0.0/0"
}
variable "aws_private_subnet_cidr" {
  default = "0.0.0.0/0"
}

variable "aws_zones" {
  type = list(string)
  default = ["eu-west-3a","eu-west-3b","eu-west-3c"]
}

variable "ubuntu_ami" {
  default = "ami-0ec59e7bad062131f"
}

variable "ssh_key_public" {
  type = string
}