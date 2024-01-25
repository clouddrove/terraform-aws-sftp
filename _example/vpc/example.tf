provider "aws" {
  region = "eu-west-1"
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source                              = "clouddrove/vpc/aws"
  version                             = "2.0.0"
  name                                = "vpc"
  environment                         = "test"
  cidr_block                          = "10.0.0.0/16"
  enable_flow_log                     = true # Flow logs will be stored in cloudwatch log group. Variables passed in default.
  create_flow_log_cloudwatch_iam_role = true
}

################################################################################
# Subnets
################################################################################

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.1"

  nat_gateway_enabled = true
  single_nat_gateway  = true
  name                = "subnets"
  environment         = "test"
  label_order         = ["environment", "name"]
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  enable_ipv6         = false
}

################################################################################
# AWS SFTP SECURITY GROUP
################################################################################

module "security_group_sftp" {
  source      = "clouddrove/security-group/aws"
  version     = "2.0.0"
  name        = "sftp-sg"
  environment = "test"
  label_order = ["environment", "name"]
  vpc_id      = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [module.vpc.vpc_cidr_block, "172.16.0.0/16"]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = ["172.16.0.0/16"]
      description = "Allow SFTP traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [module.vpc.vpc_cidr_block, "172.16.0.0/16"]
    description = "Allow ssh outbound traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = ["172.16.0.0/16"]
      description = "Allow SFTP outbound traffic."
  }]
}

################################################################################
# AWS S3
################################################################################

module "s3_bucket" {
  source  = "clouddrove/s3/aws"
  version = "2.0.0"

  name        = "clouddrove-sftp-bucket"
  environment = "test"
  label_order = ["environment", "name"]
  versioning  = true
  acl         = "private"
}

################################################################################
# AWS SFTP
################################################################################

module "sftp" {
  source                 = "../.."
  name                   = "sftp"
  environment            = "test"
  label_order            = ["environment", "name"]
  eip_enabled            = false
  s3_bucket_name         = module.s3_bucket.id
  subnet_ids             = module.subnets.private_subnet_id
  vpc_id                 = module.vpc.vpc_id
  restricted_home        = true
  vpc_security_group_ids = [module.security_group_sftp.security_group_id]
  workflow_details = {
    on_upload = {
      execution_role = "arn:aws:iam::1234567890:role/test-sftp-transfer-role"
      workflow_id    = "w-12345XXXX6da"
    }
  }
}