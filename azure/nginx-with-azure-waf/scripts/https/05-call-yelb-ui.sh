#!/bin/bash

# Variables
source ./00-variables.sh

# Call REST API
echo "Calling Yelb UI service at $URL..."
curl -w 'HTTP Status: %{http_code}\n' -s -o /dev/null $URL

# Simulate SQL injection
echo "Simulating SQL injection when calling $URL..."
curl -w 'HTTP Status: %{http_code}\n' -s -o /dev/null $URL/?users=ExampleSQLInjection%27%20--

# Simulate XSS
echo "Simulating XSS when calling $URL..."
curl -w 'HTTP Status: %{http_code}\n' -s -o /dev/null $URL/?users=ExampleXSS%3Cscript%3Ealert%28%27XSS%27%29%3C%2Fscript%3E

# A custom rule blocks any request with the word blockme in the querystring.
echo "Simulating query string manipulation with the 'blockme' word in the query string..."
curl -w 'HTTP Status: %{http_code}\n' -s -o /dev/null $URL/?users?task=blockme