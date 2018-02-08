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
    values = ["ubuntu-minecraft-forge-1.12"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "minecraft_server_svg" {
  name = "minecraft_server_svg"
  description = "Security Group for minecraft server (ssh, minecraft)"

  # Minecraft Port
  ingress {
    from_port = 25565
    to_port = 25565
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow any outband connections.
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


# The EC2 instance that will run the server
resource "aws_instance" "server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.dev.key_name}"
  security_groups = ["${aws_security_group.minecraft_server_svg.name}"]
  count = "${var.server_count}"

  tags = {
    Name = "${var.server_name} server"
  } 

  provisioner "remote-exec" {
    inline = [
      "aws configure set aws_access_key_id ${aws_iam_access_key.admin_user.id}",
      "aws configure set aws_secret_access_key ${aws_iam_access_key.admin_user.secret}",
      "aws s3 sync s3://${aws_s3_bucket.server_files.id} /home/ubuntu/",
      "sudo systemctl start minecraft-forge"
    ]
    connection {
      type     = "ssh"
      user     = "ubuntu"
    }
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo systemctl stop minecraft-forge",
      "aws s3 sync /home/ubuntu/ s3://${aws_s3_bucket.server_files.id}"
    ]
    connection {
      host     = "${aws_instance.server.public_ip}"
      type     = "ssh"
      user     = "ubuntu"
    }
  }
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
    acl    = "private"
    force_destroy = true
}
