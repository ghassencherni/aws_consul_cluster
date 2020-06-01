#----aws_consul_cluster/main.tf----

provider "aws" {
  region = "${var.aws_region}"
}

# Deploy Networking: VPC, Subnets, Internet gateway,... for our consul cluster
module "networking" {
  source             = "./networking"
  aws_region         = "${var.aws_region}"
  vpc_cidr           = "${var.vpc_cidr}"
  public_cidr_subnet = "${var.public_cidr_subnet}"
}

# Deploy Security Groups
module "security" {
  source                = "./security"
  consul_cluster_vpc_id = "${module.networking.consul_cluster_vpc_id}"
  key_name              = "${var.key_name}"
  public_key_path       = "${var.public_key_path}"
}

# Create the LoadBalancer in front of our consul cluster auto scaling group
module "load_balancer" {
  source = "./load_balancer"
  consul_cluster_elb_sg_ids         = "${module.security.consul_cluster_elb_sg_ids}"
  consul_cluster_public_subnets_ids = "${module.networking.consul_cluster_public_subnets_ids}"
}

# Deploy the auto scaling group for our consul cluster
module "auto_scaling_group" {
  source = "./auto_scaling_group"
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  auto_scaling_group_sg_id = "${module.security.auto_scaling_group_sg_id}"
  consul_cluster_public_subnets_ids = "${module.networking.consul_cluster_public_subnets_ids}"
  consul_cluster_elb_id = "${module.load_balancer.consul_cluster_elb_id}"
}

# Create a micorservice in an EC2 to test our consul cluster ( EC2 running a docker image )
module "test_microsvc" {
  source = "./test_microsvc"
  instance_type = "${var.instance_type}"
  image_id = "${var.image_id}"
  #consul_cluster_public_subnet_id_1 = "${module.networking.consul_cluster_public_subnet_id_1}"
  availability_zone = "${module.networking.availability_zone_1}"
  key_name = "${var.key_name}"
}
