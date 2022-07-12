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
  description = "(Optional) The ID of the VPC endpoint. This property can only be used when endpoint_type is set to VPC_ENDPOINT"
}

variable "vpc_id" {
  type        = string
  description = "(Optional) The VPC ID of the virtual private cloud in which the SFTP server's endpoint will be hosted. This property can only be used when endpoint_type is set to VPC."
  default     = ""
}

variable "subnet_ids" {
  description = "(Optional) A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint_type is set to VPC."
  type        = list(string)
  default     = []
}

variable "client_config" {
  type = list(object({
    user_name   = string
    client_name = string
  }))
}
