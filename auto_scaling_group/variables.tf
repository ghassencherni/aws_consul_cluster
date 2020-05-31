#----

variable "image_id" {}

variable "instance_type" {}

variable "auto_scaling_group_sg_id" {
  type = "list"
}

variable "key_name" {}

variable "consul_cluster_public_subnets_ids" {
  type = "list"
}

variable "consul_cluster_elb_id" {}
