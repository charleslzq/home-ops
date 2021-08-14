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

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
      ssh_ca_pub_key = var.ssh_ca_cert
      host_name      = var.vm_name
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }

  dynamic "part" {
    for_each = var.cloud_init_parts

    content {
      content_type = part.value.content_type
      content      = part.value.content
      merge_type   = part.value.merge_type
    }
  }
}

resource "null_resource" "cloud_init_config_files" {
  triggers = {
    file_content = data.cloudinit_config.config.rendered
  }
  connection {
    type     = "ssh"
    user     = data.vault_generic_secret.proxmox_node_settings.data.username
    password = data.vault_generic_secret.proxmox_node_settings.data.password
    host     = data.vault_generic_secret.proxmox_node_settings.data.host
  }
  provisioner "file" {
    content     = data.cloudinit_config.config.rendered
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

  cores    = var.cores
  sockets  = var.sockets
  cpu      = "host"
  memory   = var.memory
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    size     = var.disk_size
    type     = "scsi"
    storage  = data.vault_generic_secret.proxmox_node_settings.data.storage
    iothread = 1
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}
