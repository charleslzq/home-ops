# Integrate nomad and vault

1. Generate consul token for nomad client. Consul acl system and vault should be configured manually before this.
2. Generate and distribute vault configuration for nomad
3. Instruct consul template to fetch tls certificates and enable nomad mTLS.

name | type | description
--- | --- | ---
vault_address | string | the address of vault
vault_ca_int_path | string | the intermediate ca path for consul mTLS
nomad_servers | list(string) | the nomad server ips
nomad_clients | list(string) | the nomad client ips
