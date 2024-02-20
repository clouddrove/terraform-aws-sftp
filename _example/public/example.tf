provider "aws" {
  region = "eu-west-1"
}

################################################################################
# AWS S3
################################################################################

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "2.0.0"

  name        = "clouddrove-sftp-bucket01"
  environment = "test"
  label_order = ["environment", "name"]

  versioning = true
  logging    = false
  acl        = "private"
}

################################################################################
# AWS SFTP
################################################################################

module "sftp" {
  source         = "../.."
  name           = "sftp"
  environment    = "test"
  label_order    = ["environment", "name"]
  s3_bucket_name = module.s3_bucket.id
  workflow_details = {
    on_upload = {
      execution_role = "arn:aws:iam::1234567890:role/test-sftp-transfer-role"
      workflow_id    = "w-12345XXXX6da"
    }
  }
}