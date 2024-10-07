#!/usr/bin/env bash
#set -x

# Formatting variables
# Reset
Color_Off='\033[0m'       # Text Reset
Yellow='\033[0;33m'       # Yellow
BIRed='\033[1;91m'        # Red
On_Red='\033[41m'         # Red
RED='\033[0;31m'          # Red
NC='\033[0m'              # No Color

declare -a PROFILES
declare -a BUCKETS

function get_profiles() {
  PROFILES=( `awk '/profile/{print$2}' ~/.aws/config | sed 's/]//g;s/=//g;s/takeaway//g;/^$/d'`)
}

function get_buckets() {

  out=`aws --profile $1 s3api list-buckets --query "Buckets[?Name=='$2']" --output json| jq -r '.[]'`
  
  if test -z "$out"
    then
      echo -e  "Bucket ${Yellow}$2 ${Color_Off}NOT found in Account: ${Yellow}$1${NC}"
    else
      echo -e "Bucket: ${RED}$2${NC} is in Account: ${BIRed}$1${NC}"
      exit 0
  fi
}

main() {
  get_profiles
  
  for P in "${PROFILES[@]}"
  do
    get_buckets $P $1
  done
}

main $1
