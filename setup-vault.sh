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
token=$(getVKey root-token) 

if [ ! $token ]
then
    echo "Abount to initialize vault"
    vault operator init | tee /tmp/vault.init > /dev/null

    COUNTER=1
    cat /tmp/vault.init | grep '^Unseal' | awk '{print $4}' | for key in $(cat -); do
        putVKey unseal-key-$COUNTER $key
        COUNTER=$((COUNTER + 1))
    done

    token=$(cat /tmp/vault.init | grep '^Initial' | awk '{print $4}')
    export VAULT_TOKEN=$token
    putVKey root-token $token
fi

echo "Unsealing Vault"
vault operator unseal $(getVKey unseal-key-1)
vault operator unseal $(getVKey unseal-key-2)
vault operator unseal $(getVKey unseal-key-3)

echo "Vault setup complete."