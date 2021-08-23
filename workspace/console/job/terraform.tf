terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/console/job"
    gzip    = true
  }
}

provider "nomad" {
  address = "http://10.10.30.210:4646"
}
