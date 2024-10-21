#!/bin/bash

# Test the application by sending a request using curl or by using a web browser to navigate to the URL.
# It may take some time for the load balancer to become available.
kubectl wait -n yelb ingress yelb.app --for=jsonpath='{.status.loadBalancer.ingress}' 

# Get the Yelb UI app URL
YELB_URL=$(kubectl get ingress yelb.app -n yelb -o jsonpath="{.status.loadBalancer.ingress[].hostname}")

# Echo the Yelb URL
echo $YELB_URL

# Call the sample app using curl
curl $YELB_URL