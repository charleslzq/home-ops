variable "state" {
  type = string
}

variable "interface" {
  type    = string
  default = "eth0"
}

variable "router_id" {
  type = number
}

variable "priority" {
  type    = number
  default = 100
}

variable "advert_int" {
  type    = number
  default = 1
}

variable "password" {
  type = string
}

variable "ip" {
  type = string
}
