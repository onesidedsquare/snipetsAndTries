#Get all public IPs/Elastic IP addresses (EIPs) in my current account/region, 
aws ec2 describe-addresses --query 'Addresses[].PublicIp' --output text

#Get all public IPs from EC2 instances 
aws ec2 describe-instances --query 'Reservations[].Instances[].PublicIpAddress' --output text

#Get all public IPs with a given account/profile
aws ec2 describe-instances --profile changme --region changme --query 'Reservations[].Instances[].PublicIpAddress' --output text

#how to get the current EC2 instance ID
aws ec2 describe-instances --query 'Reservations[].Instances[?InstanceId==`'$(curl -s http://169.254.169.254/latest/meta-data/instance-id)'`].InstanceId' --output text

#get all EC2 instance IDs in your account
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text

#get your EC2s Security Groups
aws ec2 describe-instances --instance-ids <CHANGEID> --query 'Reservations[].Instances[].SecurityGroups[].GroupId' --output text | xargs aws ec2 describe-security-groups --group-ids

#capture input in file (adds to existing file or creates it if new)
<command> >> myoutputfile.txt

#capture output in NEW file or OVERWRITES OLD
<command> > myoutputfile.txt

#run github script from bash
curl -o script.sh https://raw.githubusercontent.com/onesidedsquare/repo/master/myscript.sh
chomd +x myscript.sh
./myscript.sh

#get your VPC Ids
aws ec2 describe-vpcs --query "Vpcs[].VpcId"

#get orphaned Security Gropus
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<your-vpc-id>" --query "SecurityGroups[?length(Attachments) == \`0\`]"
