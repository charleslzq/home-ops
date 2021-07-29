#!/bin/bash

function getVKey() { 
    value=$(consul kv get vault-keys/$1)
    if [[ $? == "0" ]]
    then 
        echo $value
    else
        echo ""
    fi
}

function putVKey() {
    consul kv put vault-keys/$1 $2
}

echo "Trying to setup vault"
vault status &> /dev/null
if [[ $? == "0" ]]
then
    echo "Vault is already unsealed"
    exit
fi

echo "Abount to unseal vault"
token=$(getVKey token/vault-token) 

if [ ! $token ]
then
    echo "Abount to initialize vault"
    vault operator init | tee /tmp/vault.init > /dev/null

    COUNTER=1
    cat /tmp/vault.init | grep '^Unseal' | awk '{print $4}' | for key in $(cat -); do
        putVKey keys/unseal-key-$COUNTER $key
        COUNTER=$((COUNTER + 1))
    done

    token=$(cat /tmp/vault.init | grep '^Initial' | awk '{print $4}')
    putVKey token/vault-token $token
fi

vault operator unseal $(getVKey keys/unseal-key-1)
vault operator unseal $(getVKey keys/unseal-key-2)
vault operator unseal $(getVKey keys/unseal-key-3)
putVKey token/vault-addr "http://127.0.0.1:8200"

echo "Vault setup complete."