provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "1.3.0"

  name        = "clouddrove-sftp-bucket"
  environment = "test"
  label_order = ["environment", "name"]

  versioning    = true
  acl           = "private"
  force_destroy = true
}

module "sftp" {
  source      = "../"
  name        = "sftp"
  environment = "test"
  label_order = ["environment", "name"]

  enable_sftp   = true
  user_name     = "ftp-user"
  s3_bucket_id  = module.s3_bucket.id
  key_path      = "~/.ssh/id_rsa.pub"
  endpoint_type = "PUBLIC"
}
