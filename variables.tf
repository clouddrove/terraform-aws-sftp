##----------------------------------------------------------------------------------
#Module      : LABEL
#Description : Terraform label module variables.
##----------------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-sftp"
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list(any)
  default     = ["transfer"]
  description = "Additional attributes (e.g. `1`)."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

##----------------------------------------------------------------------------------
#Module      : SFTP
#Description : Terraform sftp module variables.
##----------------------------------------------------------------------------------
variable "enable_sftp" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "identity_provider_type" {
  type        = string
  default     = "SERVICE_MANAGED"
  description = "The mode of authentication enabled for this service. The default value is SERVICE_MANAGED, which allows you to store and access SFTP user credentials within the service. API_GATEWAY."
}

variable "s3_bucket_name" {
  type        = string
  description = "This is the bucket that the SFTP users will use when managing files"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "VPC ID"
}

variable "domain" {
  type        = string
  description = "Where your files are stored. S3 or EFS"
  default     = "S3"
}

variable "sftp_users" {
  type        = any
  default     = {}
  description = "List of SFTP usernames and public keys. The keys `user_name`, `public_key` are required. The keys `s3_bucket_name` are optional."
}

variable "restricted_home" {
  type        = bool
  description = "Restricts SFTP users so they only have access to their home directories."
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Forces the AWS Transfer Server to be destroyed"
  default     = false
}

variable "address_allocation_ids" {
  type        = list(string)
  description = "A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "security_policy_name" {
  type        = string
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11."
  default     = "TransferSecurityPolicy-2018-11"
}

variable "retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 3
}

variable "domain_name" {
  type        = string
  description = "Domain to use when connecting to the SFTP endpoint"
  default     = ""
}

variable "zone_id" {
  type        = string
  description = "Route53 Zone ID to add the CNAME"
  default     = ""
}

variable "eip_enabled" {
  type        = bool
  description = "Whether to provision and attach an Elastic IP to be used as the SFTP endpoint. An EIP will be provisioned per subnet."
  default     = false
}

variable "workflow_details" {
  type = object({
    on_upload = object({
      execution_role = string
      workflow_id    = string
    })
  })
  description = "Workflow details for triggering the execution on file upload."
}

variable "enable_workflow" {
  type    = bool
  default = false
}