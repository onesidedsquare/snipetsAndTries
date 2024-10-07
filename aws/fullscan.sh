#/bin/bash
#temp
cd ~/aws-sg
declare -a StringArray=("labs" "staging" "pred" "sandbox" "pubcloud" "prodops" "preprod" "legacyda" "pentest")
for val in "${StringArray[@]}" ; do
  aws ec2 describe-regions --profile $val-secops --query 'Regions[*].RegionName' --output text | tr '\t' '\n' > regions_$val.txt
done
declare -a AccountArray=("labs" "staging" "pred" "sandbox" "pubcloud" "prodops" "preprod" "legacyda" "pentest")
for acct in "${AccountArray[@]}"; do
	mapfile -t RegionArray < regions_$acct.txt
	for reg in "${RegionArray[@]}"; do
		profile=$acct-secops
		acctreg=$acct
		acctreg+=$reg
		echo "$(tput setaf 3)Querying SG rules for account $acct region $reg"
		python3 ec2_sg_rules.py --region $reg --profile $profile > $acctreg.csv
	done
done
echo "$(tput setaf 6)Copying files to S3"
aws s3 sync . s3://<your-bucket>/security_groups/staging/ --exclude "*" --include "staging*.csv"
aws s3 sync . s3://<your-bucket>/security_groups/labs/ --exclude "*" --include "labs*.csv"
aws s3 sync . s3://<your-bucket>/security_groups/solutions/ --exclude "*" --include "solutions*.csv"
aws s3 sync . s3://<your-bucket>/security_groups/sandbox/ --exclude "*" --include "sandbox*.csv"
aws s3 sync . s3://<your-bucket>/security_groups/pubcloud/ --exclude "*" --include "pubcloud*.csv"
aws s3 sync . s3://<your-bucket>/security_groups/prodops/ --exclude "*" --include "prodops*.csv"
aws s3 sync . s3://<your-bucket>/security_groups/preprod/ --exclude "*" --include "preprod*.csv"
echo "$(tput setaf 5)Concatenating files and copying to S3"
cat *.csv > allsgs.csv
aws s3 cp ./allsgs.csv s3://secops-nmap/security_groups/
