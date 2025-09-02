#!/bin/sh


Image_ID="ami-09c813fb71547fc4f"
Security_Group_ID="sg-01c0372b028981e8c"
Zone_ID="Z0820810MDVVL6POTF7"
DNS="ajet142.store"
#Instances=(mongodb redis "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
Instances=("mongodb" "frontend")
array=("A" "B" "ElementC" "ElementE")

echo "$(array)"

for instances in "$(Instances[@])"
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01bc7ebe005fb1cb2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [$instances!="frontend"]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        Record_Domain="$instances.$DNS"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        Record_Domain="$DNS"
done

aws route53 change-resource-record-sets \
--hosted-zone-id $Zone_ID \
--change-batch '
{
    "Comment": "Creating or Updating a record set for cognito endpoint"
    ,"Changes": [{
    "Action"              : "UPSERT"
    ,"ResourceRecordSet"  : {
        "Name"              : "'$Record_Domain'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
    }
    }]
}'
