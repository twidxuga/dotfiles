#!/bin/bash
# Resets credentials for aws mfa cli access

PROFILE="arn:aws:iam::465543865382:mfa/ricardo.santos"

# requires yubikey manager
oathcode=$(ykman oath accounts code $PROFILE  | awk '{print $2}')

echo $oathcode

credentials=$(aws sts get-session-token --serial-number $PROFILE --token-code $oathcode --duration 129600 --profile main)

echo $credentials

accessid=$(echo $credentials | grep AccessKeyId | awk '{print $5}' | tr -d '",')
secretaccesstoken=$(echo $credentials | grep AccessKeyId | awk '{print $7}' | tr -d '",')
sessiontoken=$(echo $credentials | grep AccessKeyId | awk '{print $9}' | tr -d '",')

echo $accessid
echo $secretaccesstoken
echo $sessiontoken

#aws configure --profile mfa set aws_access_key_id $accessid
#aws configure --profile mfa set aws_secret_access_key $secretaccesstoken
#aws configure --profile mfa set aws_session_token $sessiontoken

aws configure --profile default set aws_access_key_id $accessid
aws configure --profile default set aws_secret_access_key $secretaccesstoken
aws configure --profile default set aws_session_token $sessiontoken
