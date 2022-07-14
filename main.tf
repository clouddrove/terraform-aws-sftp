locals {
  server_id = var.endpoint_type == "PUBLIC" ? join(",", aws_transfer_server.public.*.id) : join(",", aws_transfer_server.sftp_vpc.*.id)
  server_ep = var.endpoint_type == "PUBLIC" ? join(",", aws_transfer_server.public.*.endpoint) : join(",", aws_transfer_server.sftp_vpc.*.endpoint)
}


resource "aws_security_group" "sftp_vpc" {
  count       = module.this.enabled && var.endpoint_type == "VPC" && lookup(var.endpoint_details, "security_group_ids", null) == null ? 1 : 0
  name        = "${module.this.id}-sg"
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
  count                  = module.this.enabled && var.endpoint_type == "PUBLIC" ? 1 : 0
  endpoint_type          = var.endpoint_type
  protocols              = var.protocols
  certificate            = var.certificate_arn
  identity_provider_type = var.identity_provider_type
  url                    = var.api_gw_url
  invocation_role        = var.invocation_role
  directory_id           = var.directory_id
  function               = var.function_arn
  logging_role           = var.logging_role == null ? join(",", aws_iam_role.logging.*.arn) : var.logging_role
  force_destroy          = var.sftp_force_destroy
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
    security_group_ids     = lookup(var.endpoint_details, "security_group_ids", null) == null ? aws_security_group.sftp_vpc.*.id : lookup(var.endpoint_details, "security_group_ids", null)
    address_allocation_ids = lookup(var.endpoint_details, "address_allocation_ids", null) == null ? aws_eip.sftp_vpc.*.allocation_id : lookup(var.endpoint_details, "address_allocation_ids", null)
  }

  identity_provider_type = var.identity_provider_type
  url                    = var.api_gw_url
  invocation_role        = var.invocation_role
  directory_id           = var.directory_id
  function               = var.function_arn

  logging_role         = var.logging_role == null ? join(",", aws_iam_role.logging.*.arn) : var.logging_role
  force_destroy        = var.sftp_force_destroy
  security_policy_name = var.security_policy_name
  host_key             = var.host_key
  tags                 = module.this.tags
}

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


data "aws_route53_zone" "this" {
  count = module.this.enabled && var.hosted_zone != null ? 1 : 0
  name  = var.hosted_zone
}

resource "aws_route53_record" "this" {
  count   = module.this.enabled && var.hosted_zone != null ? 1 : 0
  zone_id = join(",", data.aws_route53_zone.this.*.zone_id)
  name    = var.sftp_sub_domain != "" ? "${var.sftp_sub_domain}.${var.hosted_zone}" : "${module.this.name}.${var.hosted_zone}"
  type    = "CNAME"
  ttl     = "60"
  records = [local.server_ep]
}
