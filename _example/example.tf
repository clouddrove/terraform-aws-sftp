provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "0.14.0"

  name        = "secure-bucket"
  repository  = "https://registry.terraform.io/modules/clouddrove/s3/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]

  region         = "eu-west-1"
  versioning     = true
  acl            = "private"
  bucket_enabled = true
  force_destroy  = true
}

module "sftp" {
  source      = "../"
  name        = "sftp"
  repository  = "https://github.com/clouddrove/terraform-aws-sftp"
  environment = "test"
  label_order = ["name", "environment"]

  key_path     = "~/.ssh/id_rsa.pub"
  user_name    = "ftp-user"
  enable_sftp  = true
  s3_bucket_id = module.s3_bucket.id
}
