# Config Vault Module

Generate cloud-init config for vault. Vault's backend storage is configured as consul
on the same machine, which is not included in this module. TlS is enabled, and the vault binray
should be located in directory `/mnt/cifs/cloud-init/vault/${vault_version}/`

## Input

name | type | description
--- | --- | ---
vault_version | string | the version of vault
vault_cert | string | certificate for vault tls
vault_key | string | private key for vault tls
vault_ca | string | ca certificate for vault tls
ip | string | the ip of vm


## Output

output | type | description
--- | ---| ---
cloud_init_config | string | cloud init config content, should be merge with other cloud init configs
