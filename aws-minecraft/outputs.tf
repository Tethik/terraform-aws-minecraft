output "server_ip" {
  value = "${ var.server_count > 0 ? "${join("", aws_instance.server.*.public_ip)}" : "" }"
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.server_files.arn}"
}

output "s3_bucket_aws_access_key" {
  value = "${aws_iam_access_key.admin_user.id}"
}

output "s3_bucket_aws_secret_key" {
  value = "${aws_iam_access_key.admin_user.secret}"
}


