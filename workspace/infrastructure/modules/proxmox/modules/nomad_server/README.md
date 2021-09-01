# Nomad Server Module

Setup a nomad server with acl and telemetry enabled by cloud init.
Also install consul and consul-template by consul_client module.
Will copy nomad binary from directory
`/mnt/cifs/cloud-init/nomad/${nomad_version}/`, which is mounted by cifs

# Input

name | type | description
--- | --- | ---
vm_name | string | pass to cloud_init module
proxmox_node | string | pass to cloud_init module
ssh_ca_cert | string | pass to cloud_init module
consul_version | string | the version of consul
consul_template_version | string | the version of consul-template
nomad_version | string | the version of nomad
ip | string | the ip of vm
gateway | string | the gateway of vm
server_ip_list | list(string) | the list of ips of all consul servers to form a cluster
cifs_config | string | cloud init config for cifs