terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "home/aliyun/tf"
  }
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
    }
  }
}