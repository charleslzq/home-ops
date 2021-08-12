variable "address" {
  type = string
}

variable "private_key" {
  type      = string
  sensitive = true
}

variable "dns" {
  type    = string
  default = ""
}

variable "post_up" {
  type    = string
  default = ""
}

variable "post_down" {
  type    = string
  default = ""
}

variable "listen_port" {
  type    = number
  default = 0
}

variable "peers" {
  type = list(object({
    endpoint    = optional(string)
    public_key  = string
    allowed_ips = string
    keep_alive  = optional(number)
  }))
}

variable "vm_name" {
  type = string
}

variable "proxmox_node" {
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
