
#!/bin/bash
cd /home/ssm-user/nmapproc

echo "$(tput setaf 3)Clearing last ELB scan data"
rm elbscan.xml

echo "$(tput setaf 3)Clearing ELB address list"
rm elbips.txt

echo "$(tput setaf 3)Retrieving lastest ELB address list"
aws s3 cp s3://tealium-secops-nmap/elbips.txt .

COUNTER=$(< "elbips.txt" wc -l)

echo "$(tput setaf 1)Performing NMAP scan against latest ELB IP list"
curl -X POST -H 'Content-type: application/json'\
  --data '{"text":"Scanning ELBs, IPs = '$COUNTER'"}' https://hooks.slack.com/services/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

#sudo nmap -A -sV -p- -T4 -iL elbips.txt -oX elbscan.xml
nmap -Pn -p- -T4 -iL elbips.txt -oX elbscan.xml

echo "$(tput setaf 6)Copying results files to S3"
aws s3 cp ./elbscan.xml s3://tealium-secops-nmap/nmap/elbxml/elbscan.xml

curl -X POST -H 'Content-type: application/json'
  --data '{"text":"NMAP ELB Scan Completed, Scan uploaded to /nmap/elbxml"}' https://hooks.slack.com/services/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
