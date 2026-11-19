locals {
  # Correspondances de tailles décidées par l'auteur du module.
  instance_types = {
    aws = {
      S = "t3.micro"
      M = "t3.small"
      L = "t3.medium"
    }
    gcp = {
      S = "e2-micro"
      M = "e2-small"
      L = "e2-medium"
    }
    azure = {
      S = "Standard_B1s"
      M = "Standard_B2s"
      L = "Standard_B2ms"
    }
  }

  # Marqueurs d'exemple : les images réelles dépendent du cloud, de la région
  # et parfois du compte. Les remplacer avant tout usage réel.
  images = {
    aws = {
      ubuntu = "REPLACE_ME_AWS_UBUNTU_AMI_ID"
      fedora = "REPLACE_ME_AWS_FEDORA_AMI_ID"
    }
    gcp = {
      ubuntu = "projects/REPLACE_ME/global/images/ubuntu-image"
      fedora = "projects/REPLACE_ME/global/images/fedora-image"
    }
    azure = {
      ubuntu = "/subscriptions/REPLACE_ME/resourceGroups/REPLACE_ME/providers/Microsoft.Compute/images/ubuntu"
      fedora = "/subscriptions/REPLACE_ME/resourceGroups/REPLACE_ME/providers/Microsoft.Compute/images/fedora"
    }
  }
}

resource "aws_instance" "vm" {
  count         = var.cloud == "aws" ? 1 : 0
  ami           = local.images.aws[var.image]
  instance_type = local.instance_types.aws[var.size]

  # AWS : utiliser le VPC par défaut et le premier subnet par défaut.
  subnet_id = data.aws_subnets.default.ids[0]

  tags = {
    Name = "module-example"
  }
}

data "aws_vpc" "default" {
  count   = var.cloud == "aws" ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.cloud == "aws" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

resource "google_compute_instance" "vm" {
  count        = var.cloud == "gcp" ? 1 : 0
  name         = "module-example"
  machine_type = local.instance_types.gcp[var.size]
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = local.images.gcp[var.image]
    }
  }

  # Le réseau default est un choix pédagogique, pas une recommandation générale.
  network_interface {
    network = "default"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.cloud == "azure" ? 1 : 0
  name                = "module-example"
  resource_group_name = "REPLACE_ME_RESOURCE_GROUP"
  location            = "westeurope"
  size                = local.instance_types.azure[var.size]
  admin_username      = "terraform"

  # Azure exige une NIC et une clé SSH : ce module pédagogique suppose une
  # clé publique disponible et un subnet existant choisi dans le projet.
  network_interface_ids = [azurerm_network_interface.vm[0].id]

  admin_ssh_key {
    username   = "terraform"
    public_key = "REPLACE_ME_SSH_PUBLIC_KEY"
  }

  disable_password_authentication = true
  source_image_id                 = local.images.azure[var.image]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_network_interface" "vm" {
  count               = var.cloud == "azure" ? 1 : 0
  name                = "module-example-nic"
  location            = "westeurope"
  resource_group_name = "REPLACE_ME_RESOURCE_GROUP"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/REPLACE_ME/resourceGroups/REPLACE_ME/providers/Microsoft.Network/virtualNetworks/REPLACE_ME/subnets/REPLACE_ME"
    private_ip_address_allocation = "Dynamic"
  }
}
