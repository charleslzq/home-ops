#!/bin/bash

set -e

cd /tmp
CA_CERT=consul-agent-ca.pem
CA_KEY=consul-agent-ca-key.pem
envconsul -config="/etc/envconsul.d/envconsul.hcl" -prefix=vault-keys/token vault kv get -field=ca_cert secret/home/rayleigh > $CA_CERT
envconsul -config="/etc/envconsul.d/envconsul.hcl" -prefix=vault-keys/token vault kv get -field=ca_key secret/home/rayleigh > $CA_KEY
consul tls cert create -client -dc rayleigh
rm $CA_CERT
rm $CA_KEY
