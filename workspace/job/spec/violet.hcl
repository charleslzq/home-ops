job "violet" {
  datacenters = ["roger"]
  type = "service"

  group "polipo" {
    network {
      mode = "bridge"
      port "http" {
        to = 8123
      }
    }

    service {
      name = "violet"
      port = "http"
      address_mode = "alloc"

      connect {
        sidecar_service {}
      }
    }

    task "violet" {
      driver = "docker"

      config {
        image = "vimagick/polipo"
        args = [
          "socksParentProxy=10.10.10.1:1080",
          "dnsNameServer=10.10.30.235",
        ]
      }

      resources {
        cpu = 50
        memory = 50
      }
    }
  }
}
