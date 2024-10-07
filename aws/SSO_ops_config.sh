#!/bin/zsh

#make sure jq is installed
brew list jq &> /dev/null; 
if [ $? -ne 0 ]; 
  then echo "jq is not installed.  Installing jq using brew."; 
    brew install jq; 
  else echo "jq is installed.  Moving on."; 
fi

# validate SSO login
aws sso login --profile Management_Account
aws sts get-caller-identity --profile Management_Account

#verify login
login_status=$?

if [[ $login_status -eq 0 ]]
then 
  echo "SSO login command successful"
else 
  echo "Failed SSO command get-caller-identity"; exit 1
fi

#make a backup of the current config
echo "making a backup of ~/.aws/conf file"
cp ~/.aws/config ~/.aws/config.backup.`date +"%Y-%m-%dT%H.%M.%S"`

#add the Management_Account, AFT-Management, and Takeaway account to the config file
echo "Creating your ~/.aws/config file with defaults"
echo "[profile takeaway]\nrole_arn = arn:aws:iam::379410962347:role/SSOFullAdmin\nregion = us-east-1\nsource_profile = Management_Account\n" > ~/.aws/config
echo "[profile Management_Account]\nsso_account_id = 965470391888\nsso_start_url = https://tealium-inc.awsapps.com/start\nsso_region = us-east-2\nsso_role_name = AdministratorAccess\nregion = us-east-2\n" >> ~/.aws/config
echo "[profile AFT-Management]\nsso_account_id = 766318515542\nsso_start_url = https://tealium-inc.awsapps.com/start\nsso_region = us-east-2\nsso_role_name = AdministratorAccess\nregion = us-east-2\n" >> ~/.aws/config

#rebuild the config file
echo "adding all AWS accounts to your ~/.aws/config"
aws --profile Management_Account organizations list-accounts --output json --query "Accounts[].{Id:Id, Name:Name}" | jq -r 'sort_by(.Name) | .[] | "[profile \(.Name|gsub(" ";"_")|select( ((. != "Management_Account")) and . != "AFT-Management"))]\nsso_start_url = https://tealium-inc.awsapps.com/start\nsso_region = us-east-2\nsso_account_id = \(.Id)\nsso_role_name = Admin\nregion = us-east-1\noutput = json\n"' >> ~/.aws/config

#done
echo "Done!"
