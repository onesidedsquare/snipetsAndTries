#/bin/bash
cd ~/gitleaks
nametmp=$(aws ssm get-parameter --region us-west-2 --name /github/scangit_user --query "Parameter"."Value")
unamepwdtmp=$(aws ssm get-parameter --region us-west-2 --name /github/scangit_key --query "Parameter"."Value")
uname=`echo $unametmp | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
unamepwd=`echo $unamepwdtmp | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`
echo "$(tput setaf 2)Constructing array from latest Github repo list"
readarray -t repo_array < repos.txt
rm *.json
rm *.csv
for val in "${repo_array[@]}"; do
  echo "$(tput setaf 1)Performing gitleaks scan against repo $repo"
  gitleaks --username=$uname --password=$unamepwd --repo-url=https://github.com/<your-org>/$val --report=$val.csv
done

echo "$(tput setaf 6)Copying results files to S3"
aws s3 sync . s3://<your-org>-gitleaks/ --exclude "*" --include "*.csv"
