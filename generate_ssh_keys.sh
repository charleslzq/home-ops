#!/bin/bash

set -e

if [ ! -f ~/.ssh/id_rsa ]
then
    ssh-keygen -t rsa -b 4096 -C "public@ericcharleslzq.com"
fi

CERT_FILE="/home/vagrant/.ssh/id_rsa-cert.pub"
if [ -f $CERT_FILE ]
then
    rm $CERT_FILE
fi
envconsul -config="/etc/envconsul.d/envconsul.hcl" -prefix=vault-keys/token vault write -field=signed_key vm-client-signer/sign/mac public_key=@$HOME/.ssh/id_rsa.pub > $CERT_FILE
chmod 600 $CERT_FILE