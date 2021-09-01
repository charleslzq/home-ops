# Integrate consul and vault

Require consul-template has been integrated with vault.

1. Distribute gossip keys to all consul nodes. The key is saved in vault at path `/home/consul/gossip`
3. Generate configuration for acl token and distribute them for all consul nodes except consul servers and vaults(the acl token should be configured manually to make vault functional)
4. Instruct consul template to fetch tls certificates to enable mTLS between consul nodes
5. Set vault as the ca provider, generate and distribute configurations for all consul nodes.

## Input

name | type | description
--- | --- | ---
vault_address | string | the address of vault
vault_ca_int_path | string | the intermediate ca path for consul mTLS
consul_servers | list(object) | the consul server nodes
consul_clients | list(object) | the consul client nodes, not include vaults
vaults | list(object) | the vault nodes

The fields of node object:
name | type | description
--- | --- | ---
ip | string | the ip of this node
name | string | the name of this node, used in consul acl policy
