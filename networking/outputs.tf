#-----networking/outputs.tf----

output "consul_cluster_vpc_id" {
  value = "${aws_vpc.consul_cluster_vpc.id}"
}

output "consul_cluster_public_subnets_ids" {
  value = "${aws_subnet.consul_cluster_public_subnet.*.id}"
}

#output "consul_cluster_public_subnet_id_1" {
#  value = "${aws_subnet.consul_cluster_public_subnet.1.id}"
#}

output "availability_zone_1" {
  value = "${data.aws_availability_zones.available.names.1}"
}
