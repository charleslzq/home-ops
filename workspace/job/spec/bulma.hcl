job "bulma" {
  datacenters = ["roger"]
  type = "service"

  group "wallabag" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2d"
    }

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "bulma"
      tags = ["traefik.enable=true"]
      port = "http"

      check {
        name     = "bulma alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "wallabag" {
      driver = "docker"

      config {
        image   = "wallabag/wallabag:latest"
        ports   = ["http"]
        volumes = [
          "/opt/nomad/volume/bulma/images:/var/www/wallabag/web/assets/images",
          "/opt/nomad/volume/bulma/data:/var/www/wallabag/data",
        ]
      }

      env {
        SYMFONY__ENV__DOMAIN_NAME          = "https://bulma.zenq.me"
        SYMFONY__ENV__FOSUSER_REGISTRATION = false
        SYMFONY__ENV__FOSUSER_CONFIRMATION = false
      }
    }
  }
}
