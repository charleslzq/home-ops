job "traefik" {
  datacenters = ["roger"]
  type        = "system"

  group "traefik" {
    constraint {
      attribute = "$${meta.node_type}"
      value     = "gateway"
    }

    network {
      port "http" {
        static = 8080
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "joker"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.joker.tls=true"
      ]

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v${traefik_version}"
        network_mode = "host"

        volumes = [
          "local/traefik.yml:/etc/traefik/traefik.yml",
        ]
      }

      template {
        data = <<EOF
global:
  checkNewVersion: true
  sendAnonymousUsage: false

log:
  level: INFO
  format: common

api:
  dashboard: true
  insecure: true

ping: {}

providers:
  consul:
    endpoints:
      - "127.0.0.1:8500"
  consulCatalog:
    requireConsistent: true
    exposedByDefault: false
    defaultRule: "Host(`{{ .Name }}.zenq.me`)"

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
EOF
        destination = "local/traefik.yml"
        left_delimiter = "^^"
        right_delimiter = "$$"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
