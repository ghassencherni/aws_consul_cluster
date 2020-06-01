#----

# Create the loadbalancer in front of our consul cluster ( auto scaling group )
resource "aws_elb" "consul_cluster_elb" {
  name    = "consul-cluster-elb"
  subnets = ["${var.consul_cluster_public_subnets_ids}"]

  security_groups           = ["${var.consul_cluster_elb_sg_ids}"]
  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "HTTP:8500/ui/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8500"
    instance_protocol = "http"
  }
}
