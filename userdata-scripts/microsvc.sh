#! /bin/bash

ASG_NAME=consul-cluster
REGION=eu-west-1
EXPECTED_SIZE=5
CONSUL_VERSION=1.5.3

# Install Docker
sudo su
yum update -y
yum install -y docker
service docker start

# Get my local IP address
LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sleep 60

# Get the IP of any node of the cluster ( allows consul agent to join the cluster )
NODE_ID=$(aws --region=$REGION autoscaling describe-auto-scaling-groups --auto-scaling-group-name $AUTO_SG_NAME | grep InstanceId | cut -d '"' -f4 | head -1)
NODE_IP=$(aws --region=$REGION ec2 describe-instances --query="Reservations[].Instances[].[PrivateIpAddress]" --output="text" --instance-ids="$NODE_ID")

# Run the consul agent.
docker run -d --net=host consul:$CONSUL_VERSION agent -bind=$LOCAL_IP -join=$NODE_IP

# The registratot will notify consul agent about any docker image ( auto registration )
docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://localhost:8500

# Running nginx as a microservice ( should be registred on the consul cluster )
docker run -d -p 80:80 --name nginx nginx
