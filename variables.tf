variable "endpoint_type" {
  type        = string
  default     = "VPC"
  description = "Type of SFTP server. **Valid values:** `PUBLIC`, `VPC` or `VPC_ENDPOINT`"
}

variable "protocols" {
  type        = list(string)
  default     = ["SFTP"]
  description = "List of file transfer protocol(s) over which your FTP client can connect to your server endpoint. **Possible Values:** FTP, FTPS and SFTP"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ARN of ACM certificate. Required only in case of FTPS protocol"
}

variable "endpoint_details" {
  type = object({
    vpc_id                 = optional(string)
    vpc_endpoint_id        = optional(string)
    subnet_ids             = optional(list(string))
    security_group_ids     = optional(list(string))
    address_allocation_ids = optional(list(string))
  })
  default     = {}
  description = <<-EOT
    A block required to setup SFTP server if type is set to `VPC` or `VPC_ENDPOINT`
    ```{
      vpc_id                 = (Optional) ID of VPC in which SFTP server endpoint will be hosted. Required if endpoint type is set to VPC
      vpc_endpoint_id        = (Optional) The ID of VPC endpoint to use for hosting internal SFTP server. Required if endpoint type is set to VPC_ENDPOINT
      subnet_ids             = (Optional) List of subnets ids within the VPC for hosting SFTP server endpoint. Required if endpoint type is set to VPC
      security_group_ids     = (Optional) List of security groups to attach to the SFTP endpoint. Supported only if endpoint is to type VPC. If left blank for VPC, a security group with port 22 open to the world will be created and attached
      address_allocation_ids = (Optional) List of address allocation IDs to attach an Elastic IP address to your SFTP server endpoint. Supported only if endpoint type is set to VPC. If left blank for VPC, an EIP will be automatically created per subnet and attached
    }```
  EOT
}

variable "identity_provider_type" {
  type        = string
  default     = "SERVICE_MANAGED"
  description = "Mode of authentication to use for accessing the service. **Valid Values:** `SERVICE_MANAGED`, `API_GATEWAY`, `AWS_DIRECTORY_SERVICE` or `AWS_LAMBDA`"
}

variable "api_gw_url" {
  type        = string
  default     = null
  description = "URL of the service endpoint to authenticate users when `identity_provider_type` is of type `API_GATEWAY`"
}

variable "invocation_role" {
  type        = string
  default     = null
  description = "ARN of the IAM role to authenticate the user when `identity_provider_type` is set to `API_GATEWAY`"
}

variable "directory_id" {
  type        = string
  default     = null
  description = "ID of the directory service to authenticate users when `identity_provider_type` is of type `AWS_DIRECTORY_SERVICE`"
}

variable "function_arn" {
  type        = string
  default     = null
  description = "ARN of the lambda function to authenticate users when `identity_provider_type` is of type `AWS_LAMBDA`"
}

variable "logging_role" {
  type        = string
  default     = null
  description = "ARN of an IAM role to allow to write SFTP users activity to Amazon CloudWatch logs"
}

variable "sftp_force_destroy" {
  type        = bool
  default     = true
  description = "Whether to delete all the users associated with server so that server can be deleted successfully. **Note:** Supported only if `identity_provider_type` is set to `SERVICE_MANAGED`"
}

variable "security_policy_name" {
  type        = string
  default     = "TransferSecurityPolicy-2020-06"
  description = "(Optional) Specifies the name of the security policy that is attached to the server. Possible values are `TransferSecurityPolicy-2018-11`, `TransferSecurityPolicy-2020-06`, `TransferSecurityPolicy-FIPS-2020-06` and `TransferSecurityPolicy-2022-03`. Default value is: `TransferSecurityPolicy-2018-11`."
}

variable "host_key" {
  type        = string
  default     = null
  description = "RSA private key that will be used to identify your server when clients connect to it over SFTP. "
}

variable "hosted_zone" {
  type        = string
  default     = null
  description = "Hosted zone name to create DNS entry for SFTP server"
}

variable "sftp_sub_domain" {
  type        = string
  default     = "sftp"
  description = "DNS name for SFTP server. **NOTE: Only sub-domain name required. DO NOT provide entire URL**"
}

variable "sftp_users" {
  type = list(object({
    user_name      = string
    home_directory = optional(string)
    ssh_key        = optional(string)
  }))
  default     = []
  description = <<-EOT
    Map of users with key as username and value as their home directory. Home directory is the S3 bucket path which user should have access to
    ```{
      user_name      = name_of_user
      home_directory = home_dir_path
      ssh_key        = ssh_public_key_content
    }```
  EOT
}
