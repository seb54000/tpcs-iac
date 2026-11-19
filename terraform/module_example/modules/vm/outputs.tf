output "vm_id" {
  description = "Identifiant de la VM sélectionnée."
  value = (
    var.cloud == "aws" ? aws_instance.vm[0].id :
    var.cloud == "gcp" ? google_compute_instance.vm[0].id :
    azurerm_linux_virtual_machine.vm[0].id
  )
}
