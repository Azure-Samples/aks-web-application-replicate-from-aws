#!/bin/bash

# For more information, see https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/

# Load environment variables
source ./00-variables.sh

# Check if the WAF Web ACL already exists
EXISTING_WAF_WACL_ARN=$(aws wafv2 list-web-acls \
  --region $WAF_AWS_REGION \
  --scope REGIONAL \
  --query "WebACLs[?Name=='$WAF_NAME'].ARN" \
  --output text)

if [ -z "$EXISTING_WAF_WACL_ARN" ]; then
  echo "[$WAF_NAME] WAF Web ACL does not exist. Creating a new WAF Web ACL..."
  # Create a WAF Web ACL if it does not exist
  WAF_WACL_ARN=$(aws wafv2 create-web-acl \
    --name $WAF_NAME \
    --region $WAF_AWS_REGION \
    --default-action Allow={} \
    --scope REGIONAL \
    --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=YelbWAFAclMetrics \
    --description 'WAF Web ACL for Yelb' \
    --query 'Summary.ARN' \
    --output text)
else
  # Use the existing WAF Web ACL ARN
  echo "[$WAF_NAME] WAF Web ACL already exists. Using the existing WAF Web ACL ARN..."
  WAF_WACL_ARN=$EXISTING_WAF_WACL_ARN
fi

# Echo the WAF Web ACL Amazon Resource Name (ARN)
echo $WAF_WACL_ARN

# Store the AWS WAF web ACL’s Id in a variable
WAF_WAF_ID=$(aws wafv2 list-web-acls \
  --region $WAF_AWS_REGION \
  --scope REGIONAL \
  --query "WebACLs[?Name=='$WAF_NAME'].Id" \
  --output text)

# Update the ingress and associate this AWS WAF web ACL with the ALB that the ingress uses
cat <<EOF >yelb-ingress-waf.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: yelb.app
  namespace: yelb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/wafv2-acl-arn: ${WAF_WACL_ARN}
spec:
  ingressClassName: alb 
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: yelb-ui
                port:
                  number: 80
EOF
kubectl apply -f yelb-ingress-waf.yaml

# By adding alb.ingress.kubernetes.io/wafv2-acl-arn annotation to the ingress, AWS WAF is inspecting incoming traffic.
# However, it’s not blocking any traffic yet. Before we send a request to our sample app using curl,
# let's wait for the loadbalancer to become ready for traffic
kubectl wait -n yelb ingress yelb.app --for=jsonpath='{.status.loadBalancer.ingress}'

# Get the Yelb UI app URL
YELB_URL=$(kubectl get ingress yelb.app -n yelb -o jsonpath="{.status.loadBalancer.ingress[].hostname}")
echo $YELB_URL

# Call the sample app using curl
curl $YELB_URL
