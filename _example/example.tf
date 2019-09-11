provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git?ref=tags/0.12.1"

  name        = "secure-bucket"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  region         = "eu-west-1"
  versioning     = true
  acl            = "private"
  bucket_enabled = true
  force_destroy  = true
}

module "sftp" {
  source      = "git::https://github.com/clouddrove/terraform-aws-sftp.git?ref=tags/0.12.0"
  name        = "sftp"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  key_path     = "~/.ssh/id_rsa.pub"
  user_name    = "ftp-user"
  enable_sftp  = true
  s3_bucket_id = module.s3_bucket.id
}
