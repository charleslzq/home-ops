job "fluentbit" {
  datacenters = ["roger"]
  type = "system"

  group "fluentbit" {
    network {
      mode = "bridge"
    }

    service {
      name = "fluentbit"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "loki"
              local_bind_port  = 3100
            }
          }
        }
      }
    }

    task "fluentbit" {
      driver = "docker"

      resources {
        cpu    = 50
        memory = 100
      }

      config {
        image = "grafana/fluent-bit-plugin-loki"
        volumes = [
          "local/fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf",
          "/etc/machine-id:/etc/machine-id:ro",
          "/var/log/journal:/var/log/journal",
        ]
      }

      template {
        data = <<EOF
[SERVICE]
    Log_Level debug
    Parsers_File parsers.conf
[INPUT]
    Name            systemd
    Tag             *
    Path            /var/log/journal
    Systemd_Filter    _SYSTEMD_UNIT=consul.service
    Systemd_Filter    _SYSTEMD_UNIT=nomad.service
    Systemd_Filter    _SYSTEMD_UNIT=consul_template.service
    Systemd_Filter    _SYSTEMD_UNIT=vault.service
[Output]
    Name grafana-loki
    Match *
    Url http://localhost:3100/loki/api/v1/push
    BatchWait 1s
    BatchSize 30720
    Labels {host="{{ env "attr.unique.hostname" }}"}
    LineFormat json
EOF
        destination = "local/fluent-bit.conf"
      }
    }
  }
}
