#Module      : SFTP
#Description : Terraform sftp module outputs.
output "id" {
  value       = join("", aws_transfer_server.transfer_server.*.id)
  description = "The Server ID of the Transfer Server (e.g. s-12345678)."
}

output "transfer_server_endpoint" {
  value       = join("", aws_transfer_server.transfer_server.*.endpoint)
  description = "The endpoint of the Transfer Server (e.g. s-12345678.server.transfer.REGION.amazonaws.com)."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
