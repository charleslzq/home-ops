# Integrate consul-template and vault

Require acl token for consul server and vault has already been configured.

1. Create vault policy for consul template, which makes consul template able to fetch tls certificates for consul & nomad cluster
2. Generate vault token from above policy 
3. Generate configuration for consul template and upload them to required servers. Restart consul-template service automatically.

## Input

name | type | description
--- | --- | ---
servers | string | the ips of servers those should be configured
vault_address | string | the address of vault
