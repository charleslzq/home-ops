variable "vm_name" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "consul_version" {
  type = string
}

variable "ip" {
  type = string
}

variable "gateway" {
  type = string
}

variable "ssh_ca_key" {
  type      = string
  sensitive = true
}

variable "ca_cert" {
  type      = string
  sensitive = true
}

variable "cert" {
  type      = string
  sensitive = true
}

variable "private_key" {
  type      = string
  sensitive = true
}

variable "encrypt_key" {
  type      = string
  sensitive = true
}
