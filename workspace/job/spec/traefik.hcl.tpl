job "joker" {
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
      tags = ["traefik.enable=true"]

      port = "http"

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
        volumes      = [
          "local/traefik.yml:/etc/traefik/traefik.yml",
          "local/config.yml:/etc/traefik/config/config.yml",
          "secrets/https:/etc/traefik/https",
        ]
      }

      vault {
        policies = ["${policy}"]
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
  file:
    watch: true
    directory: "/etc/traefik/config"
    debugLogGeneratedTemplate: true
  consulCatalog:
    endpoint:
      token: ${consul_token}
    requireConsistent: true
    exposedByDefault: false
    defaultRule: "Host(`{{ .Name }}.zenq.me`)"

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"
    http:
      tls: true
EOF
        destination = "local/traefik.yml"
        left_delimiter = "^^"
        right_delimiter = "$$"
      }



      template {
        data       = <<EOF
http:
  routers:
    rayleigh:
      rule: Host(`rayleigh.zenq.me`)
      service: rayleigh
    roger:
      rule: Host(`roger.zenq.me`)
      service: roger
    yakumo:
      rule: Host(`yakumo.zenq.me`)
      service: yakumo
  services:
    rayleigh:
      loadbalancer:
        servers:
          - url: http://10.10.30.99:8500
          - url: http://10.10.30.100:8500
          - url: http://10.10.30.101:8500
    roger:
      loadbalancer:
        servers:
          - url: http://10.10.30.210:4646
          - url: http://10.10.30.211:4646
          - url: http://10.10.30.212:4646
    yakumo:
      loadbalancer:
        servers:
          - url: http://10.10.30.108:5000
  serversTransports:
    internal:
      rootCAs:
        - /etc/traefik/https/ca.crt

tls:
  certificates:
    - certFile: /etc/traefik/https/fullchain.pem
      keyFile: /etc/traefik/https/privkey.pem
  stores:
    default:
      defaultCertificate:
        certFile: /etc/traefik/https/fullchain.pem
        keyFile: /etc/traefik/https/privkey.pem
  options:
EOF
        destination = "local/config.yml"
      }

      template {
        data        = <<EOF
{{ with secret "https/data/me/zenq" }}
{{ .Data.data.fullchain }}
{{ end }}
EOF
        destination = "secrets/https/fullchain.pem"
      }

      template {
        data        = <<EOF
{{ with secret "https/data/me/zenq" }}
{{ .Data.data.privkey }}
{{ end }}
EOF
        destination = "secrets/https/privkey.pem"
      }

      template {
        data        = <<EOF
${ca}
EOF
        destination = "secrets/https/ca.crt"
      }
    }
  }
}
