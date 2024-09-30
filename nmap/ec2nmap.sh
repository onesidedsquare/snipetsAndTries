#!/bin/bash
# added start stop time, changed nmap flags - srogers 20210827
# corrected text lines - srogers 20210830
# added -A to nmap command - srogers 20210831
# trying original SS from orginal command with t4 - srogers 20210901
# finalized nmap call - srogers 20210915
# added 2 slack calls - sorgers 20210917

cd /home/ssm-user/nmapproc

rm *.xml
echo "$(tput setaf 3)Clearing EC2 address list"
rm ec2ips.txt
echo "$(tput setaf 3)Retrieving lastest EC2 address list"
aws s3 cp s3://secops-nmap/ec2ips.txt .

echo "$(tput setaf 1)Performing NMAP scan against latest EC2 IP list"
curl -X POST -H 'Content-type: application/json' --data '{"text":"NMap EC2 Scan STARTED"}' https://hooks.slack.com/services/<hook>

sudo nmap -A -sV -p- -T4 -iL ec2ips.txt -oX ec2scan.xml

COUNTER=$(< "ec2ips.txt" wc -l)

echo "$(tput setaf 6)Copying results files to S3"
#aws s3 sync . s3://secops-nmap/nmap/ec2xml --exclude "*" --include "*.xml"
aws s3 cp ./ec2scan.xml s3://secops-nmap/nmap/ec2nmap.xml
curl -X POST -H 'Content-type: application/json' --data '{"text":"NMAP EC2 Scan Completed, EC2 Hosts Scaned = '$COUNTER'"}' https://hooks.slack.com/services/<hook>
