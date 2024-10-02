#!/bin/bash
siteToScan="https://my.site.com"
report="mysite.fullscan.html"

echo "Site to Scan =" $siteToScan
echo "Report Name  =" $report

curl -X POST -H 'Content-type: application/json'\
    --data '{"text":"Zap Baseline Scan STARTED for my.mysite.com"}' https://hooks.slack.com/services/<hook>

#zap-baseline.py -d -I -j \

docker run --rm -v $(pwd):/zap/wrk/:rw -t ictu/zap2docker-weekly zap-full-scan.py -a -d -I -j\
  -t $siteToScan \
  -r $report \
  --hook=zap2docker-auth-weekly/auth_hook.py \
   -z "auth.loginurl=https://my.mysite.com \
       auth.username_field="email" \
       auth.username="mysite_zapscanner@gmail.com" \
       auth.password="mypassword" \
       auth.submitaction="loginBtn" \
       auth.check_delay="20" \
       auth.check_element="main_navigation" "

echo "Scan compeleted"

aws s3 cp $report s3://secops-zap/zapscans/$report

curl -X POST -H 'Content-type: application/json'\
    --data '{"text":"Zap Baseline Scan COMPLETED for my.mysite.com"}' https://hooks.slack.com/services/<hook>
