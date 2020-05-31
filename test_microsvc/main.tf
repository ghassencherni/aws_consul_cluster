# Create EC2 instance to run microservice for test
resource "aws_instance" "microsvc_instance" {
  instance_type = "${var.instance_type}"
  ami           = "${var.image_id}"

  # Attch the same role as the auto scaling group instances ( allows to interract with the asg consule and other instances )
  iam_instance_profile = "consul_profile"

  tags {
    Name = "microsvc_instance"
  }

  key_name  = "${var.key_name}"

  subnet_id = "${var.consul_cluster_public_subnet_id_1}"

}
