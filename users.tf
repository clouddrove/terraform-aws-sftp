resource "aws_iam_role" "user" {
  for_each           = module.this.enabled && length(var.sftp_users) > 0 ? { for s in var.sftp_users : s.user_name => s } : {}
  name               = "${module.this.id}-user-${each.value.user_name}"
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
}

resource "aws_iam_role_policy" "user" {
  for_each = module.this.enabled && length(var.sftp_users) > 0 ? { for s in var.sftp_users : s.user_name => s } : {}
  name     = "${module.this.id}-user-${each.value.user_name}"
  role     = aws_iam_role.user[each.key].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AllowListingOfUserFolder",
        "Action": [
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::$${transfer:HomeBucket}"
        ],
        "Condition": {
            "StringLike": {
                "s3:prefix": [
                    "$${transfer:HomeFolder}/*",
                    "$${transfer:HomeFolder}"
                ]
            }
        }
    },
    {
      "Sid": "HomeDirObjectAccess",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObjectVersion",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
    "Resource" : [
      "arn:aws:s3:::${module.s3.s3_buckets[module.this.name].bucket_id}/${each.value.home_directory}/*",
      "arn:aws:s3:::${module.s3.s3_buckets[module.this.name].bucket_id}/${each.value.home_directory}*"
    ]
}
  ]
}
POLICY
}

resource "aws_transfer_user" "this" {
  for_each       = module.this.enabled && length(var.sftp_users) > 0 ? { for s in var.sftp_users : s.user_name => s } : {}
  server_id      = local.server_id
  user_name      = each.value.user_name
  home_directory = "/${module.s3.s3_buckets[module.this.name].bucket_id}/${each.value.home_directory}"
  role           = aws_iam_role.user[each.value.user_name].arn
  tags           = module.this.tags
}

resource "aws_transfer_ssh_key" "this" {
  for_each   = module.this.enabled && length(var.sftp_users) > 0 ? { for s in var.sftp_users : s.user_name => s } : {}
  server_id  = local.server_id
  user_name  = each.value.user_name
  body       = each.value.ssh_key
  depends_on = [aws_transfer_user.this]
}
