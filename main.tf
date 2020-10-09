## Managed By : CloudDrove
## Description : This Script is used to create Transfer Server, Transfer User And  TransferSSK_KEY.
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.13.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
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
  name               = module.labels.id
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Module      : IAM ROLE POLICY
# Description : Provides an IAM role policy.
resource "aws_iam_role_policy" "transfer_server_policy" {
  name   = module.labels.id
  role   = aws_iam_role.transfer_server_role.name
  policy = data.aws_iam_policy_document.transfer_server_assume_policy.json
}

# Module      : AWS TRANSFER SERVER
# Description : Provides a AWS Transfer Server resource.
resource "aws_transfer_server" "transfer_server" {
  count                  = var.enable_sftp ? 1 : 0
  identity_provider_type = var.identity_provider_type
  logging_role           = aws_iam_role.transfer_server_role.arn
  force_destroy          = false
  tags                   = module.labels.tags
  endpoint_type          = var.endpoint_type
  endpoint_details {
    vpc_id = "vpc-XXXXXXXXXXXXXX"
  }
}

# Module      : AWS TRANSFER USER
# Description : Provides a AWS Transfer User resource.
resource "aws_transfer_user" "transfer_server_user" {
  count          = var.enable_sftp ? 1 : 0
  server_id      = aws_transfer_server.transfer_server.*.id[0]
  user_name      = var.user_name
  role           = aws_iam_role.transfer_server_role.arn
  home_directory = format("/%s/%s", var.s3_bucket_id, var.sub_folder)
  tags           = module.labels.tags
}

# Module      : AWS TRANSFER SSH KEY
# Description : Provides a AWS Transfer User SSH Key resource.
resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  count     = var.enable_sftp ? 1 : 0
  server_id = aws_transfer_server.transfer_server.*.id[0]
  user_name = aws_transfer_user.transfer_server_user.*.user_name[0]
  body      = file(var.key_path)
}
