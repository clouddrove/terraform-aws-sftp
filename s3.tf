module "s3_bucket" {
  source                  = "git@github.com:cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.0.5"
  s3_buckets              = var.s3_buckets
  namespace               = module.this.namespace
  environment             = module.this.environment
  name                    = module.this.name
  logging_bucket_grants   = var.logging_bucket_grants
  logging_lifecycle_rules = logging_lifecycle_rules
}

variable "s3_buckets" {
  description = "s3 bucket configuration"
  type = map(object({
    acl = optional(string)
    grants = optional(list(object({
      id          = string
      type        = string
      permissions = list(string)
      uri         = string
    })))
    versioning_enabled            = optional(bool)
    sse_algorithm                 = optional(string)
    kms_master_key_arn            = optional(string)
    lifecycle_configuration_rules = any
    cors_rule_inputs = optional(list(object({
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = list(string)
      max_age_seconds = number
    })))
    s3_replication_enabled      = bool
    s3_replication_rules        = any
    custom_bucket_name          = optional(string)
    logging_enabled             = optional(bool)
    replication_logging_enabled = optional(bool)
  }))
  default = {}
}

variable "logging_lifecycle_rules" {
  description = "access logging bucket lifecycle rules"
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
  default = [{
    enabled    = true
    id         = "all-object"
    filter_and = null
    transition = [{
      days          = 30
      storage_class = "GLACIER"
    }]
    expiration = {
      days = 90
    }
    abort_incomplete_multipart_upload_days = 5
    noncurrent_version_expiration = {
      noncurrent_days = 90
    }
    noncurrent_version_transition = [{
      noncurrent_days = 1
      storage_class   = "GLACIER"
    }]
  }]
}

variable "logging_bucket_grants" {
  description = "ACL for logging bucket permission"
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = [{
    id          = null
    type        = "Group"
    permissions = ["READ_ACP", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }]
}
