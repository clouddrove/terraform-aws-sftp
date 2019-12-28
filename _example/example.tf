provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git?ref=tags/0.12.1"

  name        = "sftp"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  region         = "eu-west-1"
  versioning     = true
  acl            = "private"
  bucket_enabled = true
  force_destroy  = true
}

module "sftp" {
  source      = "./../"
  name        = "sftp"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  key_path     = "~/.ssh/id_rsa.pub"
  user_name    = "ftp-user"
  enable_sftp  = true
  s3_bucket_id = module.s3_bucket.id
}
