# Consul Server Module

Setup a consul server with acl and connect enabled by cloud init. 
Will copy consul and consul-template binary from directory 
`/mnt/cifs/cloud-init/consul/${consul_version}/` 
and `/mnt/cifs/cloud-init/consul_template/${consul_template_version}/`,
which are mounted by cifs

# Input

name | type | description
--- | --- | ---
vm_name | string | pass to cloud_init module
proxmox_node | string | pass to cloud_init module
ssh_ca_cert | string | pass to cloud_init module
consul_version | string | the version of consul
consul_template_version | string | the version of consul-template
ip | string | the ip of vm
gateway | string | the gateway of vm
server_ip_list | list(string) | the list of ips of all consul servers to form a cluster
cifs_config | string | cloud init config for cifs
