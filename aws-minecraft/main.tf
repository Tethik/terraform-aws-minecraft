# Defines a user that should be able to access the s3 bucket.
resource "aws_iam_user" "admin_user" {
  name = "${var.server_name}_file_access"
}

resource "aws_iam_access_key" "admin_user" {
  user = "${aws_iam_user.admin_user.name}"
}

resource "aws_s3_bucket_policy" "server_files" {
  bucket = "${aws_s3_bucket.server_files.id}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "Allow admin user to manipulate the bucket.",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.admin_user.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "${aws_s3_bucket.server_files.arn}",            
                "${aws_s3_bucket.server_files.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "server_files" {
  bucket_prefix = "minecraft-${var.server_name}-files" # Only alphanumeric and hyphens
  acl           = "private"
  force_destroy = true
}
