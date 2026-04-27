#!/bin/bash

# kubectl port-forward -n kong svc/kong-kong-proxy 8000:80

curl -s http://localhost:8000/httpbin/headers | jq '.headers'
curl -I http://localhost:8000/httpbin/get | grep -iE "ratelimit|status"