#!/bin/bash
# Resets credentials for aws mfa cli access
#
# Requires an IAM secret key and corresponding ID
# Assumes the following two configuration profiles - main and default
#
# Contents of ~/.aws/config:
# [main]
# region = eu-west-1
# output = text
# [default]
# region = eu-west-1
# output = text
#
# Contents of ~/.aws/credentials:
# [main]
# aws_access_key_id = <ID of the IAM user's secret key>
# aws_secret_access_key = <IAM user's secret key>
# [default]
# aws_access_key_id = 
# aws_secret_access_key = 
# aws_session_token = 

PROFILE="arn:aws:iam::465543865382:mfa/ricardo.santos"

# requires yubikey manager
# requires enabled and running pcscd.service - systemctl status pcscd.service
echo "Getting oauth account for profile : $PROFILE" 

oathcode=$(ykman oath accounts code $PROFILE  | awk '{print $2}')

echo "Oauth Code : $oathcode"

credentials=$(aws sts get-session-token --serial-number $PROFILE --token-code $oathcode --duration 129600 --profile main)

echo $credentials

accessid=$(echo $credentials | grep AccessKeyId | awk '{print $5}' | tr -d '",')
secretaccesstoken=$(echo $credentials | grep AccessKeyId | awk '{print $7}' | tr -d '",')
sessiontoken=$(echo $credentials | grep AccessKeyId | awk '{print $9}' | tr -d '",')

echo $accessid
echo $secretaccesstoken
echo $sessiontoken

aws configure --profile default set aws_access_key_id $accessid
aws configure --profile default set aws_secret_access_key $secretaccesstoken
aws configure --profile default set aws_session_token $sessiontoken
