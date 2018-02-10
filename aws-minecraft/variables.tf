variable "server_name" {
    type = "string"
}
variable "aws_access_key" {
    type = "string"
}
variable "aws_secret_key" {
    type = "string"
}
variable "server_online" {
    type = "string"
}
variable "aws_instance_type" {
    type = "string"
    default = "t2.micro"
}
variable "aws_instance_disk_size" {
    type = "string"
    default = "10"
}