resource "aws_key_pair" "keypair" {
  key_name = "sshkey-${terraform.workspace}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC61q2nSLDaIVYF/OfR/x2iX/GobdBWKxkAdSoJH2+wnbApsDJFyjl4pDccxPYXPOSBZr6+ZG3Udg+dtHutYCEztNzpOeoUwIWHAmfjt13krkqg5EUpw3U2KLq+fu6Nuq5Sn82TVcMvB9htMS30Zm1zY1DJXmNsSO4lXeyubEvZUWIaKEKgK3UbF0p3w4LS8BzVNza7fHsw0NsGjjw+sYq1iC3SCRBnDsP93j2CZI3IUIN3+o5t2BPoFLD87zFIA6EpuvUixMZcwIg+VYQd4x//wINdzopixJQESjEdD15tmKiUAMwTMw5eugSWxmncTKAn2UpeA4vGe4RLDEQlD39oKZ7M7zfDwI+S+NT4MDWwZOkvsbdwXW8QPBdWgsEYViVV00VUB2JIZpt3BU9OQAbdqbU6obgqa87MOQ/O5b4g3lTpUw8yY9RHmZw6hbNObtDlCfUYskeNQEC2trEE5hposic/P7/GJH7TZqQ8CQfPXQ9EMLXBXlIVdDk7Q4eplas= CLAUDESbastienDG@CBDC-UBUNTU-008"
}

# # Use a local file for keypair (to avoid storing it in stateFile)
# resource "aws_key_pair" "keypair" {
#     key_name = "sshkey-${terraform.workspace}"
#     public_key   = var.ssh_key_public
# }

resource "aws_instance" "front" {
  count = 2

  ami                    = var.ubuntu_ami
  subnet_id              = aws_subnet.public_subnet[count.index].id
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [
                              aws_security_group.internal_allow_all.id,
                              aws_security_group.https_http_security_group.id,
                              aws_security_group.ssh.id
                            ]
  key_name               = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name        = format("front%s-%s", count.index, terraform.workspace)
    Environment = terraform.workspace
    Role        = "front"
  }
}

resource "aws_instance" "api" {
  count = 2

  ami                    = var.ubuntu_ami
  subnet_id              = aws_subnet.private_subnet.id
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [
                              aws_security_group.internal_allow_all.id,
                              aws_security_group.ssh.id
                            ]
  key_name               = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name        = format("api%s-%s", count.index ,terraform.workspace)
    Environment = terraform.workspace
    Role        = "api"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ubuntu_ami
  subnet_id              = aws_subnet.private_subnet.id
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [
                              aws_security_group.internal_allow_all.id,
                              aws_security_group.ssh.id,
                              aws_security_group.mysql_security_group.id
                            ]
  key_name               = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name        = format("db-%s", terraform.workspace)
    Environment = terraform.workspace
    Role        = "db"
  }
}


