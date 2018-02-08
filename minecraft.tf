variable "aws_access_key" {}
variable "aws_secret_key" {}

module "aws-minecraft" {
  source = "./aws-minecraft"

  server_name = "blacknode"
  aws_secret_key = "${var.aws_secret_key}"
  aws_access_key = "${var.aws_access_key}"
  server_count = 1
}

