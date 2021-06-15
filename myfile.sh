#!/usr/bin/bash

keyname=Abhay2
instancename=tryonce
ebsname=tryebs



aws ec2 run-instances --image-id ami-0ad704c126371a549 --count 1 --instance-type t2.micro --key-name $keyname --security-group-ids sg-04fa0c7c --tag-specification "ResourceType=instance,Tags=[{Key=Name,Value=$instancename}]"


#Creating the Volume
aws ec2 create-volume --availability-zone ap-south-1a --size 5 --tag-specification "ResourceType=volume,Tags=[{Key=Name,Value=$ebsname}]"


#storing the value of Volume ID in variable volumeID
volumeID=`aws ec2 describe-volumes  --query "Volumes[*].VolumeId" --filters "Name=tag:Name,Values=$ebsname" | sed -n 2p | tr -d \"`
#Storing the value of instance ID in the Variable instanceid
instanceID=`aws ec2 describe-instances --query "Reservations[*].Instances[].InstanceId" --filter "Name=key-name,Values=$keyname" | sed -n 2p | tr -d \"`
#Attaching the volume to the instance
aws ec2 attach-volume --device /dev/xvdb --instance-id $instanceID --volume-id $volumeID
