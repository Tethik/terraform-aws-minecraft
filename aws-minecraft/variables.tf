variable "server_name" {
  type = "string"
}

variable "server_online" {
  type = "string"
}

variable "aws_instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "aws_instance_disk_size" {
  type    = "string"
  default = "10"
}

variable "aws_key_pair_key_name" {
  type    = "string"
  default = ""
}

# variable "minecraft_version" {
#     type = "string"
#     default = "1.12.2"
# }

