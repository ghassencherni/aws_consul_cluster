#----deploy_jenkins/varianles.tf----

variable "aws_region" {}

variable "key_name" {}

variable "public_key_path" {}

variable "vpc_cidr" {}

variable "public_cidr_subnet" {
  type = "list"
}

variable "public_client_cidr_subnet" {}

variable "instance_type" {}

variable "image_id" {}
