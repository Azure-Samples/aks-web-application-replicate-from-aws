#!/bin/bash

# For more information, see: 
# https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/
# https://docs.aws.amazon.com/waf/latest/APIReference/API_AWSManagedRulesBotControlRuleSet.html
# https://docs.aws.amazon.com/waf/latest/developerguide/waf-bot-control-deploying.html

# Load environment variables
source ./00-variables.sh

# Create a JSON file containing the AWSManagedRulesBotControlRuleSet rule group. 
# This rule group contains rules to block and manage requests from bots as described in AWS WAF documentation. 
# AWS WAF blocks the requests we send using curl because AWS WAF web ACL rules are configured to inspect and block requests 
# for user agent strings that don’t seem to be from a web browser.
cat << EOF > waf-rules.json 
[
    {
      "Name": "AWS-AWSManagedRulesBotControlRuleSet",
      "Priority": 0,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesBotControlRuleSet"
        }
      },
      "OverrideAction": {
        "None": {}
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWS-AWSManagedRulesBotControlRuleSet"
      }
    }
]
EOF

# Store the AWS WAF web ACL’s Id in a variable
WAF_WAF_ID=$(aws wafv2 list-web-acls \
  --region $WAF_AWS_REGION \
  --scope REGIONAL \
  --query "WebACLs[?Name=='$WAF_NAME'].Id" \
  --output text)

if [ -z "$WAF_WAF_ID" ]; then
  echo "[$WAF_NAME] WAF Web ACL does not exist."
  exit -1
fi

# Update the WAF Web ACL with the rules
aws wafv2 update-web-acl \
--name $WAF_NAME \
--scope REGIONAL \
--id $WAF_WAF_ID \
--default-action Allow={} \
--lock-token $(aws wafv2 list-web-acls \
--region $WAF_AWS_REGION \
--scope REGIONAL \
--query "WebACLs[?Name=='$WAF_NAME'].LockToken" \
--output text) \
--visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=YelbWAFAclMetrics \
--region $WAF_AWS_REGION \
--rules file://waf-rules.json