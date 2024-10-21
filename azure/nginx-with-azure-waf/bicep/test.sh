#!/bin/bash

# Variables
url="https://babo.<your-azure-dns-name-eg-contoso-com>"

# Call REST API
echo "Calling REST API..."
curl -I -s "$url"

# Simulate SQL injection
echo "Simulating SQL injection..."
curl -I -s "${url}?users=ExampleSQLInjection%27%20--"

# Simulate XSS
echo "Simulating XSS..."
curl -I -s "${url}?users=ExampleXSS%3Cscript%3Ealert%28%27XSS%27%29%3C%2Fscript%3E"

# A custom rule blocks any request with the word blockme in the querystring.
echo "Simulating query string manipulation with the 'blockme' word in the query string..."
curl -I -s "${url}?task=blockme"

# Get the workspace inference service
kubectl get svc workspace-falcon-7b-instruct --namespace kaito-demo

NAME                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)            AGE
workspace-falcon-7b-instruct   ClusterIP   172.16.255.218   <none>        80/TCP,29500/TCP   7d

# Get the workspace inference deployment
kubectl get deploy workspace-falcon-7b-instruct --namespace kaito-demo

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
workspace-falcon-7b-instruct   1/1     1            1           7d