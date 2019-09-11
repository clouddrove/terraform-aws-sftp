
output "sftp" {
  value        = module.sftp.*.id
  description = "The Server ID of the Transfer Server (e.g. s-12345678)"
}
