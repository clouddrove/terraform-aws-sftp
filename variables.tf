variable "public_key" {
  type        = string
  default     = ""
  description = "Name  (e.g. `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQ`)."
  sensitive   = true
}

variable "identity_provider_type" {
  type        = string
  default     = "SERVICE_MANAGED"
  description = "The mode of authentication enabled for this service. The default value is SERVICE_MANAGED, which allows you to store and access SFTP user credentials within the service. API_GATEWAY."
}

variable "s3_bucket_id" {
  type        = string
  description = "The landing directory (folder) for a user when they log in to the server using their SFTP client."
  sensitive   = true
}

variable "key_path" {
  type        = string
  default     = ""
  description = "Name  (e.g. `~/.ssh/id_rsa.pub`)."
  sensitive   = true
}
variable "sub_folder" {
  type        = string
  default     = ""
  description = "Landind folder."
  sensitive   = true
}

variable "endpoint_type" {
  type        = string
  default     = "PUBLIC"
  description = "The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC_ENDPOINT), your SFTP server isn't accessible over the public internet. If you want to connect your SFTP server via public internet, set PUBLIC. Defaults to PUBLIC"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID"
}

variable "client_config" {
  type = list(object({
    user_name    = string
    client_name  = string
    role         = string
    s3_bucket_id = string
  }))
}
