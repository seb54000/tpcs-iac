output "aws_vm_id" {
  description = "Identifiant de la VM créée dans AWS."
  value       = module.vm_aws.vm_id
}

output "gcp_vm_id" {
  description = "Identifiant de la VM créée dans Google Cloud."
  value       = module.vm_gcp.vm_id
}
