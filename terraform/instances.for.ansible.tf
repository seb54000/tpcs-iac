resource "aws_key_pair" "keypair_ansible_test" {
  key_name = "sshkey-ansible-test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFrYfBMIDbI0K+LqVoyT7OoEes19UKm02+cCqLIx59FRB6OT5PlSZiCbmtF35FWHVNutCzITh89fyuBqZ1E85qc7G8FoX9NG7tfoFWhsA3cVRPhHja4oTDH0TPx25BWOo5vH2nEKuRvt7FAosExWvfbMw2PithgMjC+7zCwmD1emVBoPr877zFVs4sBDc5/Q0elk09RWN7rZgerrAC8QTTrhqfYTa/r9JDZyZQjTVudtvr5T5QSUDxPkVFt2ojoTstMe4dI5B4Yhe5+bjFB4GpDOL0U9yy4zH0m6iqhv3klUt7qbipjxHji3jwT4dXZAjV+1hfOABscYtIcssMcXz3xn1q+9OdCcJEv/2YVa13UjeGQ6u24R5DJYbUJpLhS8CEOVd/fwlGhCcAyRTdrEwCnF3X8muPhiFBbkr5Rmtb1yKJa4sXjMDmGOiMwEn9iVJlfodT2kTmiPhugbiy+fsh+UsjRktQ6rg6wpvYFAo8+2n0F/Js9V1Be0i/RO5SJV0= CLAUDESbastienDG@CBDC-UBUNTU-008"
}

resource "aws_instance" "ansible_instance" {
  count = 2
  ami             = "ami-0a7899f097e6c2e90"   # https://cloud-images.ubuntu.com/locator/ec2/
  instance_type = "t2.small"
  key_name               = aws_key_pair.keypair_ansible_test.key_name
  vpc_security_group_ids =  [aws_security_group.ansible_test.id]
  tags = {
    Name = "first-ansible-vm-${count.index}"
  }
}

resource "aws_security_group" "ansible_test" {
  name        = "ansible_test"
  description = "ansible_test"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "ansible_test"
  }
}