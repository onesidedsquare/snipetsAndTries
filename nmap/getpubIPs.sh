#!/bin/bash

cd /home/ssm-user/nmapproc/pubips

curl -X POST -H 'Content-type: application/json'\
 --data '{"text":"Get Public IP START"}' https://hooks.slack.com/services/<hook>
rm *-ips.txt
rm *-ips2.txt

#all REGIONS
declare -a RegionArray=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "ca-central-1" "af-south-1" "ap-east-1" "ap-south-1" "ap-northeast-1"\
   "ap-northeast-2" "ap-northeast-3" "ap-southeast-1" "ap-southeast-2" "eu-central-1" "eu-north-1" "eu-south-1" "eu-west-1" "eu-west-2"\
   "eu-west-3" "me-south-1")

#test REGIONS
#declare -a RegionArray=("us-east-1" "us-west-1")

#all PROFILES
declare -a ProfileArray=("prodops" "preprod" "sandbox" "pubcloud")

#test PROFILES
#declare -a ProfileArray=("sandbox")

#prod PROFILES
#declare -a ProfileArray=("prodops" "preprod")

for region in "${RegionArray[@]}"; do
  echo "Region-" $region
  for profile in "${ProfileArray[@]}"; do
    echo "Profile-" $profile
    aws ec2 describe-network-interfaces \
        --profile $profile \
        --region $region \
        --profile $profile \
        --region $region \
        --query NetworkInterfaces[*].[Association.PublicIp] \
        --output text >> $region-ips.txt
  done

  #Remove Nones
  echo "removing nones and sort"
  sed '/None/d' $region-ips.txt | sort -u > $region-ips-cleaned.txt

  #send to slack counts/regions for status
  check=$(< $region-ips-cleaned.txt wc -l)
  curl -X POST -H 'Content-type: application/json'\
    --data '{"text":"Public IPs for '$region', Found:'$check'"}' https://hooks.slack.com/services/<hook>

  #Copy up the IP list
  echo "copying up to s3"
  aws s3 cp $region-ips-cleaned.txt s3://secops-nmap/pubips/$region-ips.txt
done

echo "==getpubips2 Complete=="

curl -X POST -H 'Content-type: application/json'\
 --data '{"text":"Get Public IPs COMPLETED"}' https://hooks.slack.com/services/<hook>

#clean up, because all ips are in aws
rm *
