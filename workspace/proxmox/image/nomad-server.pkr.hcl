locals {
  root_password    = vault("/secret/home/data/default", "password")
  proxmox_username = vault("/secret/home/data/proxmox", "username")
  proxmox_password = vault("/secret/home/data/proxmox", "password")
  locale           = "en_US"
}

source "proxmox" "nomad-server" {
  proxmox_url              = "https://10.10.30.168:8006/api2/json"
  insecure_skip_tls_verify = true
  node                     = "avalon"
  pool                     = "hashi"
  username                 = local.proxmox_username
  password                 = local.proxmox_password
  iso_file                 = "images:iso/ubuntu-21.04-live-server-amd64.iso"

  memory  = 2048
  sockets = 2
  cores   = 2
  os      = "l26"

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"

  disks {
    type              = "scsi"
    disk_size         = "50G"
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
    "<esc><esc><enter><wait>",
    "/install/vmlinuz ",
    "auto ",
    "console-setup/ask_detect=false ",
    "debconf/frontend=noninteractive ",
    "debian-installer=${local.locale} ",
    "hostname=nomad-server ",
    "fb=false ",
    "grub-installer/bootdev=/dev/sda<wait> ",
    "initrd=/install/initrd.gz ",
    "kbd-chooser/method=us ",
    "keyboard-configuration/modelcode=SKIP ",
    "locale=${local.locale} ",
    "noapic ",
    "passwd/username=root ",
    "passwd/user-fullname=root ",
    "passwd/user-password=${local.root_password} ",
    "passwd/user-password-again=${local.root_password} ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    "-- <enter>"
  ]

  onboot               = true
  unmount_iso          = true
  template_name        = "nomad-server-{{timestamp}}"
  template_description = "template for nomad server"
}

build {
  sources = ["source.proxmox.nomad-server"]
}

