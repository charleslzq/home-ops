variable "vm_name" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "consul_version" {
  type = string
}

variable "consul_template_version" {
  type = string
}

variable "ip" {
  type = string
}

variable "gateway" {
  type = string
}

variable "ssh_ca_cert" {
  type      = string
  sensitive = true
}

variable "server_ip_list" {
  type = list(string)
}

variable "cifs_config" {
  type = string
}

variable "nomad_version" {
  type = string
}
