#!/bin/bash

token=$(cat api_token)
api_server_url=$(cat api_server_url)

curl -k -v -H "Authorization: Bearer $token" "$api_server_url"
