#!/bin/sh

export PORT=5000 
export RACK_ENV=development 
export RAILS_ENV=development 
export DATA_ENCRYPT_KEY=secret
export WEB_CONCURRENCY=1
export SSL_CERT_FILE=/Users/trcull/dev/retentionfactory/config/curl_cacert.pem

foreman start
