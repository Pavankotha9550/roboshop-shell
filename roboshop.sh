#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0ccfe8392d60403ed"
instances=[]
zone_id="Z09059862X9S9AE54Z9SP"
domain_name="daws84.cyou"

for instances in $@
do
    instance_id=(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0ccfe8392d60403ed --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instances}]" --query "Instances[0].InstanceId" --output text)
    
    if [ $instances != "frontend" ]
    then
       ip=(aws ec2 describe-instances --instance-ids i-0abcdef123456789 --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
       ip=(aws ec2 describe-instances --instance-ids i-0abcdef123456789 --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "instance name : $instances and ip was: $ip"
done