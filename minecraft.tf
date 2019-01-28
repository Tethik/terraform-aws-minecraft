resource "aws_key_pair" "dev" {
  key_name   = "Dev (Tethik)"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

module "aws-minecraft" {
  source = "./aws-minecraft"

  server_name           = "vanilla"
  server_online         = "${var.server_online}"
  aws_instance_type     = "t2.medium"
  aws_key_pair_key_name = "${aws_key_pair.dev.key_name}"
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
