# AWS region where to run our Jenkins instance
aws_region = "eu-west-1"

# The name of the public ssh key stored in AWS
key_name = "snowplow_key"

# The public key for ssh connection 
public_key_path = "~/.ssh/id_rsa.pub"

vpc_cidr = "10.0.0.0/16"

public_cidr_subnet = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

image_id = "ami-0ea3405d2d2522162"

instance_type = "t2.micro"


## The AWS ACCESS KEY ID
#aws_access_key_id = ""
#
## The AWS SECRET ACCESS KEY
#aws_secret_access_key = ""

