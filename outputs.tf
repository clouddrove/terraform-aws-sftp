output "arn" {
  value       = var.endpoint_type == "PUBLIC" ? join(",", aws_transfer_server.public.*.arn) : join(",", aws_transfer_server.sftp_vpc.*.arn)
  description = "ARN of transfer server"
}

output "id" {
  value       = local.server_id
  description = "ID of transfer server"
}

output "endpoint" {
  value       = local.server_ep
  description = "Endpoint of transfer server"
}

# output "domain_name" {
#   value       = var.hosted_zone == null ? null : join(",", aws_route53_record.sftp.*.fqdn)
#   description = "Custom DNS name mapped in Route53 for transfer server"
# }

output "sftp_sg_id" {
  value       = var.endpoint_type == "VPC" && lookup(var.endpoint_details, "security_group_ids", null) == null ? join(",", aws_security_group.sftp_vpc.*.id) : null
  description = "ID of security group created for SFTP server. Available only if SFTP type is VPC and security group is not provided by you"
}

output "sftp_eip" {
  value       = var.endpoint_type == "VPC" && lookup(var.endpoint_details, "address_allocation_ids", null) == null ? aws_eip.sftp_vpc.*.public_ip : null
  description = "Elastic IP attached to the SFTP server. Available only if SFTP type is VPC and allocation id is not provided by you"
}
