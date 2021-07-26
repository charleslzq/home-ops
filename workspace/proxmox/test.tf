data "consul_key_prefix" "proxmox" {
    path_prefix = "home/provmox/variables"
  key {
    name = "consul_mac"
    path = "consul-address"
  }
}

resource "proxmox_vm_qemu" "test" {
  name        = "VM-test"
  target_node = "avalon"
  iso         = "images:iso/ubuntu-21.04-live-server-amd64.iso"
  os_type     = "ubuntu"

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
    model  = "virtio"
    bridge = "vmbr0"
    macaddr = data.consul_key_prefix.proxmox.var.consul_mac
  }
}


