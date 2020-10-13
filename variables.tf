#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}
#Module      : SFTP
#Description : Terraform sftp module variables.
variable "enable_sftp" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "user_name" {
  type        = string
  description = "User name for SFTP server."
}

variable "identity_provider_type" {
  type        = string
  default     = "SERVICE_MANAGED"
  description = "The mode of authentication enabled for this service. The default value is SERVICE_MANAGED, which allows you to store and access SFTP user credentials within the service. API_GATEWAY."
}
variable "s3_bucket_id" {
  type        = string
  description = "The landing directory (folder) for a user when they log in to the server using their SFTP client."
}

variable "key_path" {
  type        = string
  default     = ""
  description = "Name  (e.g. `~/.ssh/id_rsa.pub` or `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQ`)."
}
variable "sub_folder" {
  type        = string
  default     = ""
  description = "Landind folder."
}
variable "endpoint_type" {
  type        = string
  default     = "PUBLIC"
  description = "The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC_ENDPOINT), your SFTP server isn't accessible over the public internet. If you want to connect your SFTP server via public internet, set PUBLIC. Defaults to PUBLIC"
}
variable "vpc_id" {
  type        = string
  default     = "vpc-0ea04e161d1bc836d"
  description = "VPC ID"
}
