job "usopp" {
  datacenters = ["roger"]
  type = "service"

  group "whoogle" {
    network {
      port "http" {
        to = 5000
      }
    }

    service {
      name = "usopp"
      tags = ["traefik.enable=true"]
      port = "http"
    }

    task "usopp" {
      driver = "docker"

      config {
        image = "benbusby/whoogle-search:latest"
        ports = ["http"]
      }

      env {
        WHOOGLE_CONFIG_SEARCH_LANGUAGE = "English"
        WHOOGLE_CONFIG_LANGUAGE = "English"
        WHOOGLE_PROXY_TYPE = "socks5"
        WHOOGLE_PROXY_LOC = "10.10.10.1:1080"
        WHOOGLE_CONFIG_URL = "https://usopp.zenq.me"
        WHOOGLE_CONFIG_THEME = "dark"
        WHOOGLE_CONFIG_SAFE = true
        WHOOGLE_CONFIG_TOR = true
        WHOOGLE_CONFIG_NEW_TAB = true
        WHOOGLE_CONFIG_VIEW_IMAGE = true
        EXPOSE_PORT = 5000
      }
    }
  }
}
