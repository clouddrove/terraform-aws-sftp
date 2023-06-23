provider "aws" {
  region = "eu-west-1"
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.1"

  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]
  vpc_enabled = true

  cidr_block = "10.50.0.0/16"
}

################################################################################
# Subnets
################################################################################

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.0.1"

  name        = "subnets"
  environment = "test"
  label_order = ["environment", "name"]
  # tags        = local.tags
  enabled = true

  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
}

################################################################################
# AWS SFTP SECURITY GROUP
################################################################################

module "security_group-sftp" {
  source  = "clouddrove/security-group/aws"
  version = "0.15.0"

  name          = "sftp-sg"
  environment   = "test"
  protocol      = "tcp"
  label_order   = ["environment", "name"]
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["10.30.0.0/16", "192.168.5.0/24", "171.21.132.0/24"]
  allowed_ports = [27017]
}


################################################################################
# AWS S3
################################################################################

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "1.3.0"

  name        = "clouddrove-sftp-bucket01"
  environment = "test"
  label_order = ["environment", "name"]

  versioning    = true
  acl           = "private"
  force_destroy = true
}

################################################################################
# AWS SFTP
################################################################################

module "sftp" {
  source                 = "../.."
  name                   = "sftp"
  environment            = "test"
  label_order            = ["environment", "name"]
  eip_enabled            = true
  s3_bucket_name         = module.s3_bucket.id
  sftp_users             = var.sftp_users
  subnet_ids             = module.subnets.private_subnet_id
  vpc_id                 = module.vpc.vpc_id
  restricted_home        = true
  vpc_security_group_ids = [module.security_group-sftp.security_group_ids]
}