#!/bin/bash

mosquitto_pub --cafile config/server-ca.crt --cert config/client-cert.pem --key config/client-key.pem \
    -h "$(cat config/server.host)" -p \
    443 -t 'test' -m 'hello' -d