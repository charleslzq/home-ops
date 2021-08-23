variable "consul_version" {
  type = string
}

variable "consul_template_version" {
  type = string
}

variable "ip" {
  type = string
}

variable "server_ip_list" {
  type = list(string)
}
