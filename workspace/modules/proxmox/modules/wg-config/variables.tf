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
    endpoint    = string
    public_key  = string
    allowed_ips = string
    keep_alive  = number
  }))
}
