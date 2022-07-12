resource "aws_iam_role" "user" {
  for_each           = var.sftp_users
  name               = "${moule.this.id}-sftp-user-${each.key}"
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
  for_each = var.sftp_users
  name     = "${moule.this.id}-user-${each.key}"
  role     = aws_iam_role.user[each.key].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListingOfUserFolder",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::$${Transfer:HomeBucket}"
      ]
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
      "Resource": "arn:aws:s3:::${trimsuffix(each.value, "/")}/*"
    }
  ]
}
POLICY
}

resource "aws_transfer_user" "this" {
  for_each       = var.sftp_users
  server_id      = local.server_id
  user_name      = each.key
  home_directory = "/${each.value}"
  role           = aws_iam_role.user[each.key].arn
  tags           = merge({ User = each.key }, var.tags)
}

resource "aws_transfer_ssh_key" "this" {
  for_each   = var.sftp_users_ssh_key
  server_id  = local.server_id
  user_name  = each.key
  body       = each.value
  depends_on = [aws_transfer_user.this]
}
