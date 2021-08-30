variable "vault_address" {
  type = string
}

variable "vault_int_ca_path" {
  type = string
}

variable "consul_servers" {
  type = list(string)
}

variable "consul_clients" {
  type = list(string)
}
