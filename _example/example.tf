provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "0.15.1"

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
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfjNc4A+atuEBaElnpQqFkBFgGc+kCslpXh/aKETl1Wh95tOy9IWHomegVxKB44OvB5s6I6HFwRa8MCpcAUnW3vD7hBwOv+PgJ0ZFUGYrl71doDHsWtfgoRhrKlhk2jjS7gOZrrYK2vg0859knhrmRQEm6snqFdZ6bLc6R/r0htgtgUx9mESZHfupL/lylOjBiEboQxpo1lp2MKEmksv5q+8A60ZN+mTEj6M4Zmbiw7ypGjcK8utgOyoJ58uWIMt76VW46M6FIGVymwnqBm5PUgThzTPhwVpIc4kTw2Ko1CF4l8fhHNHr698NNTkpol5QvFiBZIgbTGF9RBJyYpGN1XupY4UCrwLBFb5Sigu42lCfb2/wpuAPk5LpoUhdvrDYyzxMdFy0AhIs+3my9D5jNs2rHywoYzcGfrEwi8tLHRqaV+nOI4URk7GenzAQWbUeKwosgSyVv4XnAFrtHMx2oUN5iqAMwFeZH67gw9BkATiF0ZhExCHGILcLZTNJP2N0= anmol@clouddrove-Lenov"
  user_name     = "ftp-user"
  s3_bucket_id  = module.s3_bucket.id
  endpoint_type = "PUBLIC"
}
