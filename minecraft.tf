variable "server_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-central-1"
}

resource "aws_key_pair" "dev" {
    key_name    = "Dev (Tethik)"
    public_key  = "${file("~/.ssh/id_rsa.pub")}"
}

# Defines a user that should be able to access the bucket and ec2 instance.
resource "aws_iam_user" "admin_user" {
    name = "${var.server_name}_admin"
}

resource "aws_iam_access_key" "admin_user" {
    user = "${aws_iam_user.admin_user.name}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# The EC2 instance that will run the server
resource "aws_instance" "server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
#   key_name      = "${aws_key_pair.dev.key_name}"

  provisioner "local-exec" {
    command = "echo ${aws_instance.server.public_ip} && echo ${aws_instance.server.public_ip} > ip_address.txt"
  }
  
  provisioner "local-exec" {
    command = "echo ${aws_iam_access_key.admin_user.id} && echo ${aws_iam_access_key.admin_user.id} > access-key.txt"
  }

  provisioner "local-exec" {
    command = "echo ${aws_iam_access_key.admin_user.secret} && echo ${aws_iam_access_key.admin_user.secret} > secret-key.txt"
  }
}

resource "aws_s3_bucket" "server_files" {
    bucket = "tf-minecraft-${var.server_name}-files" # Only alphanumeric and hyphens
    acl    = "private"

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
                "arn:aws:s3:::tf-minecraft-${var.server_name}-files",            
                "arn:aws:s3:::tf-minecraft-${var.server_name}-files/*"
            ]            
        }
    ]
}
EOF
}
