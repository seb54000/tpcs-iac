resource "aws_instance" "test-instance" {
  ami             = "<AMI-ID-for-your-region>"   # https://cloud-images.ubuntu.com/locator/ec2/ : Arch amd64 , Jammy or Noble
  instance_type = "t3.micro"

  tags = {
    filter = chomp(file("/etc/hostname"))
  }
}