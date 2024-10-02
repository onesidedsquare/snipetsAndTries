#!/bin/bash
curl -X POST -H 'Content-type: application/json' --data '{"text":"*'Snyk'* ignore_unfixable_issues script STARTED"}' https://hooks.slack.com/services/<hook>
month=$(date "+%b")
day=$(date "+%d")
year=$(date "+%Y")
cd /home/ec2-user

###Retrieve API token from Parameter Store
token=$(aws ssm get-parameter --region us-west-2 --name /common/Snyk/APItoken --query "Parameter.Value" --output text)

###Cleaning up yesterday's mess....
sudo rm issues-*.txt
sudo rm ignored_full-*.txt

###Running script to query Snyk API
python3 /home/ec2-user/ignore_unfixable_issues.py $token

###Stripping out duplicates
uniq issues.txt issues2.txt

###Grabbing count for comparison to Snyk Reports in console
count1=$(wc -l issues2.txt | awk '{ print $1 }')
count2=$(wc -l ignored_full.txt | awk '{ print $1 }')

###Moving file to daily naming format and copying to S3
mv issues2.txt issues-$month-$day-$year.txt
mv ignored_full.txt ignored_full-$month-$day-$year.txt
aws s3 cp /home/ec2-user/issues-$month-$day-$year.txt s3://collection/snyk/issues-$month-$day-$year.txt
aws s3 cp /home/ec2-user/ignored_full-$month-$day-$year.txt s3://collection/snyk/ignored_full-$month-$day-$year.txt

###Signing off via Slack
curl -X POST -H 'Content-type: application/json'\
 --data '{"text":"Individual Snyk issues ignored: *'$count1'* check: s3://collection/snyk/issues-$month-$day-$year.txt"}' https://hooks.slack.com/services/<hook>
curl -X POST -H 'Content-type: application/json'\
 --data '{"text":"Total ignored issues: *'$count2'* check: s3://collection/snyk/ignored_full-$month-$day-$year.txt"}' https://hooks.slack.com/services/<hook>
