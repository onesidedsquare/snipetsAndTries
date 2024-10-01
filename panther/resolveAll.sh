#!/bin/zsh

# Array of alert message titles to test for
message=(
          'This is a Test Alert'
          '.EC2.Volume.Encryption'
          '.does.not.enforce.Secure.Transport'
          '.AWS.Security.Group.Admin.or.SSH.Ingress.0.0.0.0.0' 
          '.AWS.DynamoDB.Table.Encryption'
          '.connection-attempt.failed.on.cvpn-endpoint'
          '.AWS.DynamoDB.Table.Encryption'
          '.AWS.Security.Group.Admin.or.SSH.Ingress.0.0.0.0.0'
          '.AWS.Security.Group.-.Only.DMZ.Publicly.Accessible'
          '.root.user.activity.CreateSnapshot.in.account.<hook>'
          '.root.user.activity.DeleteSnapshot.in.account.<hook>'
          '.root.user.activity.CreateTags.in.account.<hook>'
          '.AWS.S3.Bucket.Public.Read.on.publishengine-.'
          '.Integrity.checksum.changed'
          'AWS.Security.Group.-.Publicly.Accessible'
        )

for M in "${message[@]}"; do

    # output what is gettin resolved
    echo "\n\e[1;31m$M"
    for i in {1..${#M}}; do printf "\e[1;32m_"; done
    echo "\e[1;37m"
    
    # test if there are any alerts (more than zero) then keep resolving
    while ((`curl -s -X GET -H "Authorization: GenieKey $OPSGENIE_PANTHER" 'https://api.opsgenie.com/v2/alerts?query=status%3Aopen&limit=100' | jq -r --arg test "$M" '.data |.[] | select(.message|test($test)) | .tinyId' | wc -l | tr -d ' '` > 0))
    do
			# since the results are greater than zero resolve the alerts
      for T in `curl -s -X GET -H "Authorization: GenieKey $OPSGENIE_PANTHER" 'https://api.opsgenie.com/v2/alerts?query=status%3Aopen&limit=100' | jq -r --arg test "$M" '.data |.[] | select(.message|test($test)) | .tinyId'`
        do 
           printf "$T: "
           curl -s -X POST "https://api.opsgenie.com/v2/alerts/$T/close?identifierType=tiny" -H "Authorization: GenieKey $OPSGENIE_PANTHER" -H "Content-Type: application/json" -d '{ "user":"SecOps Admin", "source":"SecOps Admin", "note":"Action executed via Alert API" }'
      done
    done
done
