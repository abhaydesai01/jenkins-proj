#!/bin/bash

#Declaring Variables
keyname=testingclikey
instancename=testinginstance
sgname=testingsg
ebsname=testingebs

#creating the key pair
aws ec2 create-key-pair --key-name $keyname --tag-specification "ResourceType=key-pair,Tags=[{Key=Name,Value=$keyname}]" --query "KeyMaterial" --output text > $keyname.pem

#Creating the security group
aws ec2 create-security-group --group-name $sgname --description "created from CLI"  --vpc-id vpc-50f0e456

aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --filters Name=group-name,Values=$sgname

sgid=`aws ec2 describe-security-groups  --query "SecurityGroups[].GroupId" --filters "Name=group-name,Values=$sgname" | sed -n 2p | tr -d \"`


#Adding the inbound rules to the security group created
aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr 0.0.0.0/0

#Launching the instance
aws ec2 run-instances --image-id ami-0ad704c126371a549 --count 1 --instance-type t2.micro --key-name $keyname --security-group-ids $sgid --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$instancename}]"


#Creating the Volume
aws ec2 create-volume --availability-zone ap-south-1a --size 5 --tag-specification "ResourceType=volume,Tags=[{Key=Name,Value=$ebsname}]"

#storing the value of Volume ID in variable volumeID
volumeID=`aws ec2 describe-volumes  --query "Volumes[*].VolumeId" --filters "Name=tag:Name,Values=$ebsname" | sed -n 2p | tr -d \"`
#Storing the value of instance ID in the Variable instanceid
instanceID=`aws ec2 describe-instances --query "Reservations[*].Instances[].InstanceId" --filter "Name=key-name,Values=$keyname" | sed -n 2p | tr -d \"`
#Attaching the volume to the instance
aws ec2 attach-volume --device /dev/xvdb --instance-id $instanceID --volume-id $volumeID
