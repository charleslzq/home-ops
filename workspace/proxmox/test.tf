locals {
  proxmox_node = "avalon"
}

data "consul_keys" "proxmox" {
  key {
    name = "consul_mac"
    path = "proxmox/consul-mac"
  }
  key {
    name = "proxmox_host"
    path = "proxmox/nodes/${local.proxmox_node}/host"
  }
  key {
    name = "proxmox_zfs"
    path = "proxmox/nodes/${local.proxmox_node}/local-zfs"
  }
}

data "vault_generic_secret" "default" {
  path = "secret/home/default"
}

data "vault_generic_secret" "proxmox_node_credentials" {
  path = "secret/home/proxmox/${local.proxmox_node}"
}

data "vault_generic_secret" "ssh_ca" {
  path = "vm-client-signer/config/ca"
}

resource "local_file" "cloud_init_user_data_file" {
  content = templatefile("${path.module}/files/cloud-init.tpl", {
    ssh_ca_pub_key = data.vault_generic_secret.ssh_ca.data.public_key
  })
  filename = "${path.module}/generated/cloud-init.yml"
}

resource "null_resource" "cloud_init_config_files" {
  triggers = {
    file_content = local_file.cloud_init_user_data_file.content
  }
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.proxmox_node_credentials.data.username
    password = data.vault_generic_secret.proxmox_node_credentials.data.password
    host     = data.consul_keys.proxmox.var.proxmox_host
  }
  provisioner "file" {
    source      = local_file.cloud_init_user_data_file.filename
    destination = "/mnt/pve/images/snippets/cloud-init.yml"
  }
}

resource "proxmox_vm_qemu" "test" {
  name                      = "VM-test"
  target_node               = local.proxmox_node
  clone                     = "ubuntu-cloudinit"
  os_type                   = "cloud-init"
  ciuser                    = "ubuntu"
  cipassword                = data.vault_generic_secret.default.data.password
  cicustom                  = "user=images:snippets/cloud-init.yml"
  cloudinit_cdrom_storage   = data.consul_keys.proxmox.var.proxmox_zfs
  ipconfig0                 = "ip=10.10.30.99/24,gw=10.10.30.1"
  guest_agent_ready_timeout = 120

  cores    = 1
  sockets  = "1"
  cpu      = "host"
  memory   = 1024
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    size     = "20G"
    type     = "scsi"
    storage  = "local-zfs"
    iothread = 1
  }
  network {
    model   = "virtio"
    bridge  = "vmbr0"
    macaddr = data.consul_keys.proxmox.var.consul_mac
  }
}


