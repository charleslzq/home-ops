# Integration module

Integrate consul, vault and nomad.

## Requirement

After infrastructure module has been applied, some manually work should be done before run this. 
See readme of proxmox module in infrastructure folder.

## Consul template

Configure it to fetch secrets from vault. Basically used for mTLS certificate generation for consul & nomad cluster.

## Consul

Require consul template has been integrated with vault. 

1. Use gossip encrypt key stored in vault
2. Generate agent acl token for consul clients.
3. Setup mTLS for consul, using certificates in vault
4. Setup mTLS for consul connect, using vault as ca provider

## Nomad

Require consul template has been integrated with vault. 

1. Generate consul token for nomad nodes
2. Make nomad able to use secrets in vault
3. Setup mTLS for nomad, using certificates in vault

