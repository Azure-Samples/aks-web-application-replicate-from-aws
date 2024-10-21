#!/bin/bash

# For more information, see: 
# https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/
# https://docs.aws.amazon.com/waf/latest/APIReference/API_AWSManagedRulesBotControlRuleSet.html
# https://docs.aws.amazon.com/waf/latest/developerguide/waf-bot-control-deploying.html

# Load environment variables
source ./00-variables.sh

# Get the Yelb UI app URL
YELB_URL=$(kubectl get ingress yelb.app -n yelb -o jsonpath="{.status.loadBalancer.ingress[].hostname}")
echo $YELB_URL

# Call the sample app using curl
curl $YELB_URL

# Print a separator
printf '%.s-' {1..80}; echo

# Call the sample app using curl with a user agent string that AWS WAF will block
curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" $YELB_URL
