#!/bin/bash

set -e

cd /tmp
dc=$1
if [ -z "$dc" ]; then
  echo "You need to specify the name of dc"
  exit 1
fi
CA_CERT=consul-agent-ca.pem
CA_KEY=consul-agent-ca-key.pem
envconsul -config="/etc/envconsul.d/envconsul.hcl" -prefix=vault-keys/token vault kv get -field=ca_cert secret/home/consul > $CA_CERT
envconsul -config="/etc/envconsul.d/envconsul.hcl" -prefix=vault-keys/token vault kv get -field=ca_key secret/home/consul > $CA_KEY
consul tls cert create -client -dc $dc
rm $CA_CERT
rm $CA_KEY
