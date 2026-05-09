
# Use a local file for keypair (to avoid storing it in stateFile)
resource "aws_key_pair" "keypair" {
  key_name   = "sshkey-tpiac-demoboard-${chomp(file("/etc/hostname"))}"
  public_key = var.ssh_key_public
  tags = {
    Name   = "keypair-tpiac-demoboard-${chomp(file("/etc/hostname"))}"
    filter = chomp(file("/etc/hostname"))
  }
}

resource "aws_instance" "front" {
  count = 2

  ami           = var.ubuntu_ami
  subnet_id     = aws_subnet.public_subnet[count.index].id
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.internal_allow_all.id,
    aws_security_group.https_http_security_group.id,
    aws_security_group.ssh.id
  ]
  key_name = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name         = format("front%s", count.index)
    Role         = "front"
    api_lb_dns   = aws_lb.lb_api.dns_name
    front_lb_dns = aws_lb.lb_front.dns_name
    db_host      = aws_instance.db.private_dns
    redis_host   = aws_instance.redis.private_dns
    filter       = chomp(file("/etc/hostname"))
  }
}

resource "aws_instance" "api" {
  count = 2

  ami           = var.ubuntu_ami
  subnet_id     = aws_subnet.private_subnet[count.index].id
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.internal_allow_all.id,
    aws_security_group.ssh.id,
    aws_security_group.api_security_group.id
  ]
  key_name = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name         = format("api%s", count.index)
    Role         = "api"
    api_lb_dns   = aws_lb.lb_api.dns_name
    front_lb_dns = aws_lb.lb_front.dns_name
    db_host      = aws_instance.db.private_dns
    redis_host   = aws_instance.redis.private_dns
    filter       = chomp(file("/etc/hostname"))
  }
}

resource "aws_instance" "worker" {
  count = 2

  ami           = var.ubuntu_ami
  subnet_id     = aws_subnet.private_subnet[count.index].id
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.internal_allow_all.id,
    aws_security_group.ssh.id
  ]
  key_name = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name         = format("worker%s", count.index)
    Role         = "worker"
    api_lb_dns   = aws_lb.lb_api.dns_name
    front_lb_dns = aws_lb.lb_front.dns_name
    db_host      = aws_instance.db.private_dns
    redis_host   = aws_instance.redis.private_dns
    filter       = chomp(file("/etc/hostname"))
  }
}

resource "aws_instance" "db" {
  ami           = var.ubuntu_ami
  subnet_id     = aws_subnet.private_subnet[0].id
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.internal_allow_all.id,
    aws_security_group.ssh.id,
    aws_security_group.postgres_security_group.id
  ]
  key_name = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 24
  }

  tags = {
    Name         = "db"
    Role         = "db"
    api_lb_dns   = aws_lb.lb_api.dns_name
    front_lb_dns = aws_lb.lb_front.dns_name
    filter       = chomp(file("/etc/hostname"))
  }
}

resource "aws_instance" "redis" {
  ami           = var.ubuntu_ami
  subnet_id     = aws_subnet.private_subnet[1].id
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.internal_allow_all.id,
    aws_security_group.ssh.id,
    aws_security_group.redis_security_group.id
  ]
  key_name = aws_key_pair.keypair.key_name

  root_block_device {
    volume_size = 16
  }

  tags = {
    Name         = "redis"
    Role         = "redis"
    api_lb_dns   = aws_lb.lb_api.dns_name
    front_lb_dns = aws_lb.lb_front.dns_name
    filter       = chomp(file("/etc/hostname"))
  }
}
