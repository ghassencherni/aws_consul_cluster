#---- 

# Create the launch configuration for the auto scaling group
resource "aws_launch_configuration" "auto_scaling_group_config" {
  name = "consul-cluster"
  image_id        = "${var.image_id}"
  instance_type   = "${var.instance_type}"

  #security_groups = ["sg-033b66e2cf5702a3a"]
  
  security_groups = ["${var.auto_scaling_group_sg_id}"]
  key_name = "${var.key_name}"

  user_data = "${file("userdata-scripts/consul-cluster-init.sh")}"
  
  #Allow consul to interract with other instances
  iam_instance_profile = "consul_profile" 

  lifecycle {
    create_before_destroy = true
  }
}

# 
resource "aws_autoscaling_group" "consul-cluste-auto-scaling-group" {
  name = "consul-cluster"

  min_size             = 5
  #desired_capacity     = 5
  max_size             = 5

  load_balancers= [
    "${var.consul_cluster_elb_id}"
  ]

  launch_configuration = "${aws_launch_configuration.auto_scaling_group_config.name}"
  
  # spin up instances on the three AZ ( 3 subnets )
  vpc_zone_identifier = ["${var.consul_cluster_public_subnets_ids}"]

  # Allow to update instance without an outage
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "consule"
    propagate_at_launch = true
  }
}
