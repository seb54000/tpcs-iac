# Les credentials restent à l'extérieur du code (profils, variables d'environnement
# ou identité managée). Les emplacements sont des choix fixes de cet exemple.
provider "aws" {
  region = "eu-west-1"
}

provider "google" {
  project = "REPLACE_ME_GCP_PROJECT"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

provider "azurerm" {
  features {}
}
