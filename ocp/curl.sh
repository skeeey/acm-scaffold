#!/bin/bash

token=$(cat api_server.token)
api_server_url=$(cat api_server_url)

default_configmaps="/api/v1/namespaces/default/configmaps/"

curl -k -v -H "Authorization: Bearer $token" "https://$api_server_url:6443"
