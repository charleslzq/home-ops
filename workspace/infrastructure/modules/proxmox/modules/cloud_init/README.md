# Cloud Init Module

* start a vm on proxmox use cloud init

## Setting

* A template named ubuntu-cloudinit should exist on every node of proxmox cluster. To create one, see: [Proxmox Cloud-Init Support](https://pve.proxmox.com/wiki/Cloud-Init_Support)
* Proxmox node specific setting should be stored in vault at path `secret/home/proxmox/${proxmox_node}`, mainly used for ssh connection and upload files. Uploaded cloud-init config file will be located at `/mnt/pve/images/snippets/cloud-init-${var.vm_name}.yml`, which is reference in proxmox vm setting as `user=images:snippets/cloud-init-${var.vm_name}.yml`

name | type | description
--- | --- | ---
host | string | node host
username | string | ssh username
password | string | ssh password
storage | string | disk storage for vm

## Input

name | type | default | description
--- | --- | --- | ---
vm_name | string | | the name of vm, should be unique in the cluster
ssh_ca_cert | string | | ssh ca certificate
proxmox_node | string | | proxmox node the vm will be created on
cloud_ip_config | string | | ip related config, like: `ip=192.168.1.2/24,gw=192.168.1.1`
cloud_init_parts | list | | additional cloud init config
cores | number | 1 | the number of cpu cores
sockets | string | "1" | the number of cpu sockets
memory | number | 1024 | memory size
disk_size | string | "20G" | disk size
storage | string | "" | disk storage for vm, will use storage in setting if not set

The fields of objects in cloud_init_parts are:
name | type | description
--- | --- | ---
content_type | string | the type of cloud config. See: [Cloud Init Mime Types](https://cloudinit.readthedocs.io/en/latest/topics/format.html)
content | string | content of config file
merge_type | string | instructions on how to merge this config. See: [Merge Cloud Init User Sections](https://cloudinit.readthedocs.io/en/latest/topics/merging.html)
