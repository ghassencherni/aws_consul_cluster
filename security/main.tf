# Create our key pair, to allow us to connect to our instance with ssh if needed
resource "aws_key_pair" "my_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Allow to get My Public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Creation of the public security group for our consul cluster (auto scaling group) 
resource "aws_security_group" "auto_scaling_group_sg" {
  name        = "auto-scaling-group-sg"
  description = "SG of the auto scaling group"
  vpc_id      = "${var.consul_cluster_vpc_id}"

  # Allow SSH from our public IP
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    # Allow only our public IP to connect to the instance
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  # Allow HTTP API
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Consul DNS
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Consul DNS
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Serf LAN
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Serf LAN
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Serf WAN
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Serf WAN
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Server RPC
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the security group for our LoadBalancer placed in front of the consul cluster
resource "aws_security_group" "consul_cluster_elb_sg" {
  name        = "consul_cluster_elb"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id      = "${var.consul_cluster_vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Allow HTTP through ELB Security Group"
  }
}

### Create IAM instance profile for our auto scaling group ( allows consul to gather data from other ec2 instances )
# Create the policy
resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = "${aws_iam_role.consul_ec2_role.id}"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:Describe*",
          "ec2:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# Create the role
resource "aws_iam_role" "consul_ec2_role" {
  name = "consul_ec2_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul_profile" {
  name = "consul_profile"
  role = "${aws_iam_role.consul_ec2_role.name}"
}
