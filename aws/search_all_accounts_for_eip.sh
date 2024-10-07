#!/usr/bin/env bash
source ./text_colors.sh

declare -a PROFILES
declare -a REGIONS

echo "" > /tmp/eips.txt

function get_profiles() {
  PROFILES=( `awk '/profile/{print$2}' ~/.aws/config | sed 's/]//g;s/=//g;s/takeaway//g;/^$/d'`)
}

function get_regions() {
  REGIONS=(`aws --profile $1 ec2 describe-regions --query "Regions[*].[RegionName]" --output text`)
}

function get_eips() {

  out=`aws --profile $1 --region $2 ec2 describe-addresses --query "Addresses[].PublicIp" --output json | jq -r '.[]'`
  
  if test -z "$out"
    then
      echo -e  "No EIPs in Account: ${Yellow}$1${NC} Region: ${Red}$2${NC}"
    else
      echo -e "EIPs in Account: ${BIRed}$1${NC} Region: ${Red}$2${NC}:"
      echo -e "${BIGreen}$out${NC}"
      echo -e "EIPs in Account: ${BIRed}$1${NC} Region: ${Red}$2${NC}:" >> /tmp/eips.txt
      echo -e "${BIGreen}$out${NC}" >> /tmp/eips.txt
      if test -z "$3"
        then 
          printf ''
        else
          if [[ "$out" == *"$3"* ]]; then
          echo -e "${BIRed}${Blink}MATCH${NC}: IP ${On_IGreen}$3${NC} is in Account: ${BICyan}$1${NC} Region: ${BIYellow}$2${NC}"
          say -v Fiona "I P $3 was found."
          fi
      fi
  fi
}

main() {
  get_profiles
  
  for P in "${PROFILES[@]}"
  do
    get_regions $P 
    for R in "${REGIONS[@]}"
      do get_eips $P $R $1 &
    done
  done
  echo "check temp file /tmp/eips.txt for a list of all the EIPs found"
}

main $1
