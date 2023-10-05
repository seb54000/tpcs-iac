resource "aws_instance" "test-instance" {
  ami             = "ami-0a7899f097e6c2e90"   # https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "t2.small"

#   vpc_security_group_ids = [aws_security_group.tpkube_secgroup.id]
#   key_name      = aws_key_pair.tpkube_key.key_name
#   user_data     = data.template_file.user_data.rendered

#   root_block_device {
#     volume_size = 20 # in GB
#   }

  tags = {
    # tpcentrale = "tpcentrale"
    Name = "my-test-vm"
  }

#   lifecycle {
#     ignore_changes = [ user_data ]
#   }
}