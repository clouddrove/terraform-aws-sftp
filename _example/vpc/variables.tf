variable "sftp_users" {
  type = list(object({
    username = string
    password = string
    home_dir = string
  }))
  default = []
}

variable "eip_enabled" {
  type        = bool
  description = "Whether to provision and attach an Elastic IP to be used as the SFTP endpoint. An EIP will be provisioned per subnet."
  default     = false
}
