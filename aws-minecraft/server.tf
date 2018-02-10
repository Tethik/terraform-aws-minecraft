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

  # owners = ["099720109477"] # Todo fix this to the packer ami.
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
  instance_type = "${var.aws_instance_type}"
  key_name      = "${aws_key_pair.dev.key_name}"
  security_groups = ["${aws_security_group.minecraft_server_svg.name}"]
  count = "${var.server_online == "yes" ? "1" : "0"}"

  root_block_device = {
      volume_type = "gp2"
      volume_size = "${var.aws_instance_disk_size}"
  }

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