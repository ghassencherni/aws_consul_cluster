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
  
  #availability_zone = "${var.availability_zone}"
  subnet_id = "${var.subnet_id}"
  security_groups = ["${var.security_groups}"]
  #vpc_security_group_ids = "${var.vpc_security_group_ids}"
  user_data = "${file("userdata-scripts/microsvc.sh")}"
}
