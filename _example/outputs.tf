output "id" {
  value       = module.sftp.*.id
  description = "The Server ID of the Transfer Server (e.g. s-12345678)"
}

output "tags" {
  value       = module.sftp.tags
  description = "A mapping of tags to assign to the SFTP."
}
