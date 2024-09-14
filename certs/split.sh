#!/bin/bash

awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/{split_after=1}{print > ("cert" n ".pem")}' chain.pem
