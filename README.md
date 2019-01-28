# terraform-aws-minecraft

Terraform and packer script to launch an on-demand minecraft server using aws.

The terraform configs will launch an ec2 instance that can be turned on or off. An s3 bucket is created
for long term storage of the server files.

To launch a server setup:

```
terraform apply
```

To destroy everything (including backup):

```
terraform destroy
```
