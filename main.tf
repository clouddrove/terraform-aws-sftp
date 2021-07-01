## Managed By : CloudDrove
## Description : This Script is used to create Transfer Server, Transfer User And  TransferSSK_KEY.
## Copyright @ CloudDrove. All Right Reserved.

#Module      : labels
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = var.attributes
  label_order = var.label_order
}


data "aws_iam_policy_document" "transfer_server_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "transfer_server_assume_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = ["*"]
  }
}

# Module      : IAM ROLE
# Description : This data source can be used to fetch information about a specific IAM role.
resource "aws_iam_role" "transfer_server_role" {
  count = var.enable_sftp ? 1 : 0

  name               = module.labels.id
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Module      : IAM ROLE POLICY
# Description : Provides an IAM role policy.
resource "aws_iam_role_policy" "transfer_server_policy" {
  count = var.enable_sftp ? 1 : 0

  name   = module.labels.id
  role   = join("", aws_iam_role.transfer_server_role.*.name)
  policy = data.aws_iam_policy_document.transfer_server_assume_policy.json
}

# Module      : AWS TRANSFER SERVER
# Description : Provides a AWS Transfer Server resource.
resource "aws_transfer_server" "transfer_server" {
  count = var.enable_sftp && var.endpoint_type == "PUBLIC" ? 1 : 0

  identity_provider_type = var.identity_provider_type
  logging_role           = join("", aws_iam_role.transfer_server_role.*.arn)
  force_destroy          = false
  tags                   = module.labels.tags
  endpoint_type          = var.endpoint_type
}
#with VPC endpoint
resource "aws_transfer_server" "transfer_server_vpc" {
  count = var.enable_sftp && var.endpoint_type == "VPC" ? 1 : 0

  identity_provider_type = var.identity_provider_type
  logging_role           = join("", aws_iam_role.transfer_server_role.*.arn)
  force_destroy          = false
  tags                   = module.labels.tags
  endpoint_type          = var.endpoint_type
  endpoint_details {
    vpc_id = var.vpc_id
  }
}

# Module      : AWS TRANSFER USER
# Description : Provides a AWS Transfer User resource.
resource "aws_transfer_user" "transfer_server_user" {
  count = var.enable_sftp ? 1 : 0

  server_id      = var.endpoint_type == "VPC" ? join("", aws_transfer_server.transfer_server_vpc.*.id) : join("", aws_transfer_server.transfer_server.*.id)
  user_name      = var.user_name
  role           = join("", aws_iam_role.transfer_server_role.*.arn)
  home_directory = format("/%s/%s", var.s3_bucket_id, var.sub_folder)
  tags           = module.labels.tags
}

# Module      : AWS TRANSFER SSH KEY
# Description : Provides a AWS Transfer User SSH Key resource.
resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  count = var.enable_sftp ? 1 : 0

  server_id = join("", aws_transfer_server.transfer_server.*.id)
  user_name = join("", aws_transfer_user.transfer_server_user.*.user_name)
  body      = var.public_key == "" ? file(var.key_path) : var.public_key
}
