locals {
  server_id = var.sftp_type == "PUBLIC" ? join(",", aws_transfer_server.public.*.id) : join(",", aws_transfer_server.sftp_vpc.*.id)
  server_ep = var.sftp_type == "PUBLIC" ? join(",", aws_transfer_server.public.*.endpoint) : join(",", aws_transfer_server.sftp_vpc.*.endpoint)
}


resource "aws_security_group" "sftp_vpc" {
  count       = module.this.enabled && var.endpoint_type == "VPC_ENDPOINT" && lookup(var.endpoint_details, "security_group_ids", null) == null ? 1 : 0
  name        = "${local.name}-sftp-vpc"
  description = "Security group for ${module.this.id}"
  vpc_id      = lookup(var.endpoint_details, "vpc_id")

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow connections from any source on port 22"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound connections"
  }

  tags = module.this.tags
}

resource "aws_eip" "sftp_vpc" {
  count = module.this.enabled && var.endpoint_type == "VPC" && lookup(var.endpoint_details, "address_allocation_ids", null) == null ? length(lookup(var.endpoint_details, "subnet_ids")) : 0
  vpc   = true
  tags  = module.this.tags
}

resource "aws_transfer_server" "public" {
  count                  = var.sftp_type == "PUBLIC" ? 1 : 0
  endpoint_type          = var.sftp_type
  protocols              = var.protocols
  certificate            = var.certificate_arn
  identity_provider_type = var.identity_provider_type
  url                    = var.api_gw_url
  invocation_role        = var.invocation_role
  directory_id           = var.directory_id
  function               = var.function_arn
  logging_role           = var.logging_role == null ? join(",", aws_iam_role.logging.*.arn) : var.logging_role
  force_destroy          = var.force_destroy
  security_policy_name   = var.security_policy_name
  host_key               = var.host_key

  tags = module.this.tags
}

resource "aws_transfer_server" "sftp_vpc" {
  count         = module.this.enabled && var.endpoint_type != "PUBLIC" ? 1 : 0
  endpoint_type = var.endpoint_type
  protocols     = var.protocols
  certificate   = var.certificate_arn

  endpoint_details {
    vpc_id                 = lookup(var.endpoint_details, "vpc_id", null)
    vpc_endpoint_id        = lookup(var.endpoint_details, "vpc_endpoint_id", null)
    subnet_ids             = lookup(var.endpoint_details, "subnet_ids", null)
    security_group_ids     = lookup(var.endpoint_details, "security_group_ids", aws_security_group.sftp_vpc.*.id)
    address_allocation_ids = lookup(var.endpoint_details, "address_allocation_ids", aws_eip.sftp_vpc.*.allocation_id)
  }

  identity_provider_type = var.identity_provider_type
  url                    = var.api_gw_url
  invocation_role        = var.invocation_role
  directory_id           = var.directory_id
  function               = var.function_arn

  logging_role         = var.logging_role == null ? join(",", aws_iam_role.logging.*.arn) : var.logging_role
  force_destroy        = var.force_destroy
  security_policy_name = var.security_policy_name
  host_key             = var.host_key
  tags                 = module.this.tags
}

# Module      : AWS TRANSFER USER
# Description : Provides a AWS Transfer User resource.
# resource "aws_transfer_user" "transfer_server_user" {
#   for_each = module.this.enabled && length(var.client_config) > 0 ? { for s in var.client_config : s.user_name => s } : {}

#   server_id      = var.endpoint_type == "VPC" ? join("", aws_transfer_server.transfer_server_vpc.*.id) : join("", aws_transfer_server.transfer_server.*.id)
#   user_name      = each.value.user_name
#   role           = join("", aws_iam_role.transfer_server_role.*.arn)
#   home_directory = format("/%s/%s", module.s3.bucket_id, each.value.client_name)
#   tags           = merge(module.this.tags, { for k, v in var.client_config : s.client_name => v.client_name })
# }

# Module      : AWS TRANSFER SSH KEY
# Description : Provides a AWS Transfer User SSH Key resource.
# resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
#   count = module.this.enabled ? 1 : 0

#   server_id = join("", aws_transfer_server.transfer_server.*.id)
#   user_name = join("", aws_transfer_user.transfer_server_user.*.user_name)
#   body      = var.public_key == "" ? file(var.key_path) : var.public_key
# }


resource "aws_iam_role" "logging" {
  count = module.this.enabled ? 1 : 0
  name  = "${module.this.id}-transfer-logging"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = module.this.tags
}

resource "aws_iam_role_policy" "logging" {
  count = module.this.enabled ? 1 : 0
  name  = "${module.this.id}-transfer-logging"
  role  = join(",", aws_iam_role.logging.*.id)

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:DescribeLogStreams",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
