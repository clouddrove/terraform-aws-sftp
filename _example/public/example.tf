provider "aws" {
  region = "eu-west-1"
}

################################################################################
# AWS S3
################################################################################

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "1.3.0"

  name        = "sftp-bucket-457188"
  environment = "test"
  label_order = ["environment", "name"]

  versioning    = true
  logging       = true
  acl           = "private"
  force_destroy = true
}

################################################################################
# AWS SFTP
################################################################################

module "sftp" {
  source         = "/home/vaibhav/workspace/sftp-terraform-fix/testing-sftp-oci/new-sftp-fork/terraform-aws-sftp"
  name           = "sftp"
  environment    = "test"
  label_order    = ["environment", "name"]
  enable_sftp    = true
  s3_bucket_name = module.s3_bucket.id
  endpoint_type  = "PUBLIC"
  workflow_details = {
    on_upload = {
      execution_role = ""
      workflow_id    = ""
    }
  }
}