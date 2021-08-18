variable "consul_version" {
  type = string
}

variable "ip" {
  type = string
}

variable "ca_cert" {
  type      = string
  sensitive = true
}

variable "cert" {
  type      = string
  sensitive = true
}

variable "key" {
  type      = string
  sensitive = true
}

variable "encrypt_key" {
  type      = string
  sensitive = true
}

variable "server_ip_list" {
  type = list(string)
}
