resource "aws_instance" "test-instance" {
  ami             = "ami-0a7899f097e6c2e90"   # https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "t3.small"

  tags = {
    filter = chomp(file("/etc/hostname"))
  }  
}