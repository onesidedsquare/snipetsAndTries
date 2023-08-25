#!/bin/bash
siteToScan="https://mysite.com
report="mysite.fullscan.html"

echo "Site to Scan =" $siteToScan
echo "Report Name =" $report

curl -X POST -H 'Content-type: application/json'\
    --data '{"text":"ZAProxy Baseline Scan STARTED for mysite.com"}' <<changeme webhook>>

#This conducts a full scan of mysid.com
docker run -v $(pwd):/zap/wrk/:rw\
 -t owasp/zap2docker-stable\
 zap-full-scan.py -a -d -I -j\
 -c zap.conf\
 -t $siteToScan\
 -r $report

echo "Scan compeleted"

aws s3 cp $report s3://mysite-security-automation/zaproxy-scans/$report

curl -X POST -H 'Content-type: application/json'\
    --data '{"text":"ZAProxy Baseline Scan COMPLETED for mysite.com"}' <<changeme webhook>>
