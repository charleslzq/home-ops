job "mihawk" {
  datacenters = ["roger"]
  type = "service"

  group "monitoring" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "joker-1"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "prometheus" {
      driver = "docker"

      template {
        destination = "local/prometheus.yml"
        data = <<EOH
global:
  scrape_interval:     5s
  evaluation_interval: 5s

scrape_configs:
  - job_name: 'nomad_metrics'
    consul_sd_configs:
      - server: 'http://10.10.30.99:8500'
        services: ['nomad-client', 'nomad']
    relabel_configs:
      - source_labels: ['__meta_consul_tags']
        regex: '(.*)http(.*)'
        action: keep
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
EOH
      }

      config {
        image = "prom/prometheus:latest"
        args = [
          "--storage.tsdb.retention.size=5GB",
          "--config.file=/etc/prometheus/prometheus.yml",
        ]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]
        port_map {
          prometheus_ui = 9090
        }
      }

      resources {
        cpu = 100
        memory = 100
        network {
          mbits = 10
          port "prometheus_ui" {}
        }
      }

      service {
        name = "mihawk"
        tags = ["traefik.enable=true"]
        port = "prometheus_ui"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
