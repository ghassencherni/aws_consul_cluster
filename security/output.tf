#----

output "auto_scaling_group_sg_id" {
  value = "${aws_security_group.auto_scaling_group_sg.*.id}"
}

output "consul_cluster_elb_sg_ids" {
  value = "${aws_security_group.consul_cluster_elb_sg.*.id}"
}


