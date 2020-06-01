#----

variable "instance_type" {}

variable "image_id" {}

#variable "consul_cluster_public_subnet_id" {}

#variable "availability_zone" {}

variable "key_name" {}

variable "security_groups" {
  type = "list"
}

#variable "security_groups" {}

#variable "vpc_security_group_ids" {
#  type = "list"
#}


variable "subnet_id" {}
