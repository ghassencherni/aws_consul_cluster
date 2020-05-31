#! /bin/bash

AUTO_SG_NAME=consul-cluster
REGION=eu-west-1
EXPECTED_SIZE=5
CONSUL_VERSION=1.5.3

# Install docker and run the service
yum install -y docker
usermod -a -G docker ec2-user
service docker start

# Fonction returns of list of id of all instances of the cluster 
function get-cluster-instances-id {
    
	aws --region="$REGION" autoscaling describe-auto-scaling-groups --auto-scaling-group-name $AUTO_SG_NAME | grep InstanceId | cut -d '"' -f4

}


# Fonction returns the private IP of each instance in the cluster, will be iused by consul to join the cluster
function get-all-cluster-ips {
    
	for instance_id in $(get-cluster-instances-id )
	do
        aws --region="$REGION" ec2 describe-instances --query="Reservations[].Instances[].[PrivateIpAddress]" --output="text" --instance-ids="$instance_id"
    done

}


# wiat for the auto scling group to launch expected instances number 
while COUNT=$(get-cluster-instances-id | wc -l) && [ "$COUNT" -lt "$EXPECTED_SIZE" ]
do
    echo "$COUNT instances in the cluster now, waiting for expected cluster instances : $EXPECTED_SIZE "
    sleep 1
done


# Get my local IP address
LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# Get All the IPS of this region ( cluster IP and all EC2 instances IP running ) 
mapfile -t ALL_IPS < <(get-all-cluster-ips)

OTHER_IPS=( ${ALL_IPS[@]/${LOCAL_IP}} )


# Running consul as server and join the cluster 
docker run -d --net=host \
    --name=consul \
    consul:${CONSUL_VERSION} agent -server -ui \
    -bind="$LOCAL_IP" -retry-join="${OTHER_IPS[0]}" -retry-join="${OTHER_IPS[1]}" \
    -retry-join="${OTHER_IPS[2]}" -retry-join="${OTHER_IPS[3]}" \
    -bootstrap-expect="$EXPECTED_SIZE" -client=0.0.0.0

