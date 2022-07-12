# Module      : IAM ROLE
# Description : This data source can be used to fetch information about a specific IAM role.
resource "aws_iam_role" "transfer_server_role" {
  count = module.this.enabled ? 1 : 0

  name               = module.this.id
  assume_role_policy = data.aws_iam_policy_document.transfer_server_assume_role.json
}

# Module      : IAM ROLE POLICY
# Description : Provides an IAM role policy.
resource "aws_iam_role_policy" "transfer_server_policy" {
  count = module.this.enabled ? 1 : 0

  name   = module.this.id
  role   = join("", aws_iam_role.transfer_server_role.*.name)
  policy = data.aws_iam_policy_document.transfer_server_assume_policy.json
}

# Module      : AWS TRANSFER SERVER
# Description : Provides a AWS Transfer Server resource.
resource "aws_transfer_server" "transfer_server" {
  count = module.this.enabled && var.endpoint_type == "PUBLIC" ? 1 : 0

  identity_provider_type = var.identity_provider_type
  logging_role           = join("", aws_iam_role.transfer_server_role.*.arn)
  force_destroy          = false
  tags                   = module.this.tags
  endpoint_type          = var.endpoint_type
}

resource "aws_transfer_server" "transfer_server_vpc" {
  count = module.this.enabled && var.endpoint_type == "VPC_ENDPOINT" ? 1 : 0

  identity_provider_type = var.identity_provider_type
  logging_role           = join("", aws_iam_role.transfer_server_role.*.arn)
  force_destroy          = false
  tags                   = module.this.tags
  endpoint_type          = var.endpoint_type
  endpoint_details {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }
}

# Module      : AWS TRANSFER USER
# Description : Provides a AWS Transfer User resource.
resource "aws_transfer_user" "transfer_server_user" {
  for_each = module.this.enabled && length(var.client_config) > 0 ? { for s in var.client_config : s.user_name => s } : {}

  server_id      = var.endpoint_type == "VPC" ? join("", aws_transfer_server.transfer_server_vpc.*.id) : join("", aws_transfer_server.transfer_server.*.id)
  user_name      = each.value.user_name
  role           = join("", aws_iam_role.transfer_server_role.*.arn)
  home_directory = format("/%s/%s", module.s3.bucket_id, each.value.client_name)
  tags           = merge(module.this.tags, { for k, v in var.client_config : s.client_name => v.client_name })
}

# Module      : AWS TRANSFER SSH KEY
# Description : Provides a AWS Transfer User SSH Key resource.
# resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
#   count = module.this.enabled ? 1 : 0

#   server_id = join("", aws_transfer_server.transfer_server.*.id)
#   user_name = join("", aws_transfer_user.transfer_server_user.*.user_name)
#   body      = var.public_key == "" ? file(var.key_path) : var.public_key
# }
