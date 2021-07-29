locals {
  proxmox_node = "avalon"
  vm_name = "consul-server"
}

data "vault_generic_secret" "proxmox_node_settings" {
  path = "secret/home/proxmox/${local.proxmox_node}"
}

data "vault_generic_secret" "ssh_ca" {
  path = "vm-client-signer/config/ca"
}

resource "local_file" "cloud_init_user_data_file" {
  content = templatefile("${path.module}/files/cloud-init.tpl", {
    ssh_ca_pub_key = data.vault_generic_secret.ssh_ca.data.public_key
    host_name = local.vm_name
  })
  filename = "${path.module}/generated/cloud-init-${local.vm_name}.yml"
}

resource "null_resource" "cloud_init_config_files" {
  triggers = {
    file_content = local_file.cloud_init_user_data_file.content
  }
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.proxmox_node_settings.data.username
    password = data.vault_generic_secret.proxmox_node_settings.data.password
    host     = data.vault_generic_secret.proxmox_node_settings.data.host
  }
  provisioner "file" {
    source      = local_file.cloud_init_user_data_file.filename
    destination = "/mnt/pve/images/snippets/cloud-init-${local.vm_name}.yml"
  }
}

resource "proxmox_vm_qemu" "consul-server" {
  name                      = local.vm_name
  target_node               = local.proxmox_node
  clone                     = "ubuntu-cloudinit"
  os_type                   = "cloud-init"
  cicustom                  = "user=images:snippets/cloud-init-${local.vm_name}.yml"
  cloudinit_cdrom_storage   = data.vault_generic_secret.proxmox_node_settings.data.storage
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
  }
}


