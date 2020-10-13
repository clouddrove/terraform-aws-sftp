provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source = "git::https://github.com/clouddrove/terraform-aws-s3.git"

  name        = "secure-bucket"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]


  versioning     = true
  acl            = "private"
  bucket_enabled = true
  force_destroy  = true
}

module "sftp" {
  source      = "../"
  name        = "sftp"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  key_path      = "~/.ssh/id_rsa.pub"
  user_name     = "ftp-user"
  enable_sftp   = true
  s3_bucket_id  = module.s3_bucket.id
  endpoint_type = "PUBLIC"
}
