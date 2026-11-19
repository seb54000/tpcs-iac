# Deux appels au même module : chacun choisit son cloud, son gabarit et son image.
# Les valeurs autorisées et leurs validations sont définies dans le module.
module "vm_aws" {
  source = "./modules/vm"

  cloud = "aws"
  size  = "M"
  image = "ubuntu"
}

module "vm_gcp" {
  source = "./modules/vm"

  cloud = "gcp"
  size  = "L"
  image = "fedora"
}
