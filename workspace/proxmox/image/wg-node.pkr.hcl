locals {
  root_password    = vault("/secret/home/data/default", "password")
  proxmox_username = vault("/secret/home/data/proxmox", "username")
  proxmox_password = vault("/secret/home/data/proxmox", "password")
}

source "proxmox" "wg-node" {
  proxmox_url              = "https://10.10.30.168:8006/api2/json"
  insecure_skip_tls_verify = true
  node                     = "avalon"
  pool                     = "hashi"
  username                 = local.proxmox_username
  password                 = local.proxmox_password
  iso_file                 = "images:iso/alpine-standard-3.14.0-x86_64.iso"

  memory  = 512
  sockets = 1
  cores   = 1
  os      = "l26"

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"

  disks {
    type              = "scsi"
    disk_size         = "3G"
    storage_pool      = "local-zfs"
    storage_pool_type = "zfs"
    format            = "raw"
  }

  ssh_username = "root"
  ssh_password = local.root_password
  ssh_timeout  = "35m"

  http_directory = "./http"
  boot_wait      = "15s"
  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait10>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/wg.answerfile<enter><wait5>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup.sh<enter><wait5>",
    "setup-alpine -f $PWD/wg.answerfile<enter>",
    "<wait10>",
    "${local.root_password}<enter><wait>",
    "${local.root_password}<enter><wait>",
    "<wait10>",
    "y<enter>",
    "<wait10><wait10><wait10><wait10>",
    "reboot<enter>",
    "<wait90>",
    "root<enter>",
    "${local.root_password}<enter><wait>",
    "chmod +x $PWD/setup.sh<enter>",
    "$PWD/setup.sh<enter>"
  ]

  onboot               = true
  unmount_iso          = true
  template_name        = "wg-node"
  template_description = "template for wireguard"
}

build {
  sources = ["source.proxmox.wg-node"]
  provisioner "file" {
    source      = "scripts"
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "ls -la /tmp",
      "cd /tmp/scripts",
      "chmod +x setup-wg.sh",
      "./setup-wg.sh",
    ]
  }
}

