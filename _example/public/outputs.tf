output "id" {
  description = "ID of the created example"
  value       = module.sftp.id
}

output "transfer_endpoint" {
  description = "Endpoint for your SFTP connection"
  value       = module.sftp.transfer_endpoint
}