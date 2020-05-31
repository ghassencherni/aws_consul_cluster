#----

output "consul_cluster_elb_id" {
  value = "${aws_elb.consul_cluster_elb.id}"
}

output "consul-dns-name" {
 value = "${aws_elb.consul_cluster_elb.dns_name}"
}
