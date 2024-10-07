#!/usr/bin/env bash
#set -x

declare -a PROFILES
declare -a BUCKETS

function get_profiles() {
  PROFILES=( `awk '/profile/{print$2}' ~/.aws/config | sed 's/]//g;s/=//g;s/takeaway//g;/^$/d'`)
}

function encrypt_bucket() {
  aws --profile $1 s3api put-bucket-encryption --bucket $2 --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
}

function get_buckets() {
  unset BUCKETS
  BUCKETS=( `aws --profile $1 s3api list-buckets --query "Buckets[].Name" --output text` )
}

function get_bucket_encryption() {
  output=`aws --profile $1 s3api get-bucket-encryption --bucket $2 --query "ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.SSEAlgorithm" 2>1`
  status=$?
  [ $status -eq 0 ] && echo "$1,$2,encrypted" || echo "$1,$2,NOT ENCRYPTED! - Encrypting now."; encrypt_bucket $1 $2
}

main() {
  get_profiles
  
  for P in "${PROFILES[@]}"
  do
    get_buckets $P 
    for B in "${BUCKETS[@]}"
    do
      get_bucket_encryption $P $B
    done
  done
}

main
