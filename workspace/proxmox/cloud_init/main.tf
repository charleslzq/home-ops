terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

data "vault_generic_secret" "proxmox_node_settings" {
  path = "secret/home/proxmox/${var.proxmox_node}"
}

resource "null_resource" "cloud_init_config_files" {
  triggers = {
    file_content = var.cloud_init_content
  }
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.proxmox_node_settings.data.username
    password = data.vault_generic_secret.proxmox_node_settings.data.password
    host     = data.vault_generic_secret.proxmox_node_settings.data.host
  }
  provisioner "file" {
    content     = var.cloud_init_content
    destination = "/mnt/pve/images/snippets/cloud-init-${var.vm_name}.yml"
  }
}

resource "proxmox_vm_qemu" "cloud-init-server" {
  name                      = var.vm_name
  target_node               = var.proxmox_node
  onboot                    = true
  clone                     = "ubuntu-cloudinit"
  os_type                   = "cloud-init"
  cicustom                  = "user=images:snippets/cloud-init-${var.vm_name}.yml"
  cloudinit_cdrom_storage   = data.vault_generic_secret.proxmox_node_settings.data.storage
  ipconfig0                 = var.cloud_ip_config
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
    storage  = data.vault_generic_secret.proxmox_node_settings.data.storage
    iothread = 1
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}
