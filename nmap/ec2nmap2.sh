#!/bin/bash
#remove old ips
rm ~/nmapproc/pubips/*.txt

cd /home/ssm-user/nmapproc/pubips_scans
#clean out pubips_scans so new files can be created
rm *.xml

#download fresh ips lists
echo "$(tput setaf 3)Retrieving lastest EC2 address lists"
aws s3 cp s3://secops-nmap/pubips ~/nmapproc/pubips --recursive

echo "$(tput setaf 1)Performing NMAP scan against latest EC2 IP list"
curl -X POST -H 'Content-type: application/json'\
 --data '{"text":"NMap EC2 Scan STARTED"}' https://hooks.slack.com/services/<hook>

#get list of files(by region) in the pubips
arr=(ls ~/nmapproc/pubips/*)

#for each ip in the files
for cnt in ${!arr[@]}; do

  check=$(< "${arr[cnt]}" wc -l)
  #check to make sure there are lines in the files
  if [ "$check" -ne 0 ]   #gt
  then
    curl -X POST -H 'Content-type: application/json'\
     --data '{"text":"NMap EC2 Scanning '${arr[cnt]}', IPs- '$check'"}' https://hooks.slack.com/services/<hook>

    #this gets the file name from the path out of the array
    fn=$(basename -s .txt ${arr[cnt]})

    echo "$(tput setaf 1)Performing NMAP scan against '$fn'"
    #THE MAGIC
    nmap -Pn -p- -T4 -iL ${arr[cnt]} -oX $fn.scan.xml >> $fn.nmap.command.output.txt

    #DEBUG CHK  >> PT2 is BREAK
    #fn="16.162.180.124"
    #nmap 16.162.180.124 -oX $fn.scan.xml >> $fn.nmap.command.output.txt

    #check to see if scan ran
    filesize=$(wc -l < ~/nmapproc/pubips_scans/$fn.scan.xml)
    #check file line count
    if [ "$filesize" -le 20 ]; then
       curl -X POST -H 'Content-type: application/json'\
         --data '{"text":"'$fn' scan output  sugguests scan issue"}' https://hooks.slack.com/services/<hook>
       echo "$(tput setaf 1)NMAP scan output '$fn' sugguests fail"
    fi ##end filesize check

    #THE UPLOAD
    aws s3 cp $fn.scan.xml s3://secops-nmap/pubips_scans/$fn.scan.xml
    aws s3 cp $fn.nmap.command.output.txt s3://secops-nmap/pubips_scans_cmd/$fn.nmap.command.output.txt

    #DEBUG pt2
    #break

  fi ##end file length check
done ##end cnt array

echo "$(tput setaf 6)Copied results files to S3, /nmap"

curl -X POST -H 'Content-type: application/json'\
 --data '{"text":"NMAP EC2 Scan Completed?"}' https://hooks.slack.com/services/T03C0KZ9C/<hook>
