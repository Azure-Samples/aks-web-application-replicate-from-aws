# For more information, see https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/

WAF_AWS_REGION="us-east-2" 
WAF_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
WAF_EKS_CLUSTER_NAME="waf-eks-sample"
WAF_NAME="WAF-FOR-YELB"