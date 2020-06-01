#----networking/main.tf----

# Allows access to the list of AWS Availability within the region configured in the provider
data "aws_availability_zones" "available" {}

# Creation of the Custom VPC
resource "aws_vpc" "consul_cluster_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "consul_cluster_vpc"
  }
}

# Creation of Internet gateway and attach it to our new VPC
resource "aws_internet_gateway" "consul_cluster_netgate" {
  vpc_id = "${aws_vpc.consul_cluster_vpc.id}"

  tags {
    Name = "consul_cluster_netgate"
  }
}

# Creation  of the public route table ( associated with the internet gateway ) and defining the route to the internet
resource "aws_route_table" "consul_cluster_pub_rt" {
  vpc_id = "${aws_vpc.consul_cluster_vpc.id}"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.consul_cluster_netgate.id}"
  }

  tags {
    Name = "consul_cluster_pub_rt"
  }
}

# Creation of the public subnests reserved for our consul cluster ( auto scaling group ) : at three subnets
resource "aws_subnet" "consul_cluster_public_subnet" {
  count                   = 3
  vpc_id                  = "${aws_vpc.consul_cluster_vpc.id}"
  cidr_block              = "${var.public_cidr_subnet[count.index]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name      = "consul_cluster_public_subnet_${count.index + 1}"
    "cluster" = "consul"
  }
}

# Create public subnet for our consul client ( run with a microservice, k8s, ..)
resource "aws_subnet" "consul_client_public_subnet" {
  vpc_id                  = "${aws_vpc.consul_cluster_vpc.id}"
  cidr_block              = "${var.public_client_cidr_subnet}"
  map_public_ip_on_launch = true
  #availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name      = "consul_client_public_subnet"
  }
}

# Associate our public subnets to the public route table 
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 3
  subnet_id      = "${aws_subnet.consul_cluster_public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.consul_cluster_pub_rt.id}"
}

# Associate our client public subnets to the public route table
resource "aws_route_table_association" "public_client_rt_assoc" {
  subnet_id      = "${aws_subnet.consul_client_public_subnet.id}"
  route_table_id = "${aws_route_table.consul_cluster_pub_rt.id}"
}
