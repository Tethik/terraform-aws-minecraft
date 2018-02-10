variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "server_online" {}

module "aws-minecraft" {
  source = "./aws-minecraft"

  server_name = "blacknode"
  aws_secret_key = "${var.aws_secret_key}"
  aws_access_key = "${var.aws_access_key}"
  server_online = "${var.server_online}"
  aws_instance_type = "t2.medium"
}

output "minecraft_server_ip" {
  value = "${module.aws-minecraft.server_ip}"
}
output "minecraft_s3" {
  value = "${module.aws-minecraft.s3_bucket_arn}"
}
output "minecraft_s3_aws_access_key" {
  value = "${module.aws-minecraft.s3_bucket_aws_access_key}"
}
output "minecraft_s3_aws_secret_key" {
  value = "${module.aws-minecraft.s3_bucket_aws_secret_key}"
}
