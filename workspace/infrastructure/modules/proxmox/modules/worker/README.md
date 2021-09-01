# Worker Module

Setup a worker node using nomad_client and consul_client module. 
Will copy nomad binary from directory
`/mnt/cifs/cloud-init/nomad/${nomad_version}/`, which is mounted by cifs

# Input

name | type | default |  description
--- | --- | --- | ---
vm_name | string | | pass to cloud_init module
proxmox_node | string | | pass to cloud_init module
ssh_ca_cert | string | | pass to cloud_init module
consul_version | string | | the version of consul
consul_template_version | string | | the version of consul-template
nomad_version | string | | the version of nomad
ip | string | | the ip of vm
gateway | string | | the gateway of vm
server_ip_list | list(string) | | the list of ips of all consul servers to form a cluster
cifs_config | string | | cloud init config for cifs
cores | number | 1 | the number of cpu cores
sockets | string | "1" | the number of cpu sockets
memory | number | 1024 | memory size
disk_size | string | "20G" | disk size
node_type | string | "worker" | will add an entry in meta of nomad client config
additional_cloud_init_config | list(object) | [] | additional cloud init configs, See cloud_init module for object fields