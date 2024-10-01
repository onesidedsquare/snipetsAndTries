
#!/bin/bash
cd /home/ssm-user/nmapproc
rm Redshiftscan.xml

echo "$(tput setaf 3)Clearing Redshift address list"
rm Redshiftips.txt

echo "$(tput setaf 3)Retrieving lastest Redshift address list"
aws s3 cp s3://secops-nmap/Redshiftips.txt .

COUNTER=$(< "Redshifitips.txt" wc -l)

curl -X POST -H 'Content-type: application/json'
  --data '{"text":"Redshift Scan Started, IPs = '$COUNTER'"}' https://hooks.slack.com/services/<hook>

echo "$(tput setaf 1)Performing NMAP scan against latest Redshift IP list"
nmap -Pn -p- -T4 -iL Redshifitips.txt -oX Redshiftscan.xml

echo "$(tput setaf 6)Copying results files to S3"
aws s3 cp ./Redshiftscan.xml s3://secops-nmap/nmap/redshiftxml/Redshiftscan.xml
curl -X POST -H 'Content-type: application/json'
  --data '{"text":"NMAP Redshift Scan Completed, Scan uploaded to /nmap/redshiftxml"}' https://hooks.slack.com/services/<hook>
