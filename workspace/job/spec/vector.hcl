job "vector" {
  datacenters = ["roger"]
  # system job, runs on all nodes
  type = "system"
  update {
    min_healthy_time = "10s"
    healthy_deadline = "5m"
    progress_deadline = "10m"
    auto_revert = true
  }
  group "vector" {
    count = 1
    restart {
      attempts = 3
      interval = "10m"
      delay = "30s"
      mode = "fail"
    }
    network {
      port "api" {
        to = 8686
      }
    }
    ephemeral_disk {
      size    = 500
      sticky  = true
    }
    task "vector" {
      driver = "docker"
      config {
        image = "timberio/vector:latest-alpine"
        ports = ["api"]
        volumes      = [
          "/var/run/docker.sock:/var/run/docker.sock",
        ]
      }
      # Vector won't start unless the sinks(backends) configured are healthy
      env {
        VECTOR_CONFIG = "local/vector.toml"
        VECTOR_REQUIRE_HEALTHY = "true"
      }
      # resource limits are a good idea because you don't want your log collection to consume all resources available
      resources {
        cpu    = 100
        memory = 64
      }
      # template with Vector's configuration
      template {
        destination = "local/vector.toml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter = "[["
        right_delimiter = "]]"
        data=<<EOH
data_dir = "alloc/data/vector/"
[api]
enabled = true
address = "0.0.0.0:8686"
playground = true
[sources.logs]
type = "docker_logs"
[sinks.out]
type = "console"
inputs = [ "logs" ]
encoding.codec = "json"
[sinks.loki]
type = "loki"
inputs = ["logs"]
endpoint = "http://10.10.30.125:3100"
encoding.codec = "json"
healthcheck.enabled = true
# since . is used by Vector to denote a parent-child relationship, and Nomad's Docker labels contain ".",
# we need to escape them twice, once for TOML, once for Vector
labels.alloc_id = "{{ label.com\\.hashicorp\\.nomad\\.alloc_id }}"
labels.job = "{{ label.com\\.hashicorp\\.nomad\\.job_name }}"
labels.task = "{{ label.com\\.hashicorp\\.nomad\\.task_name }}"
labels.group = "{{ label.com\\.hashicorp\\.nomad\\.task_group_name }}"
labels.namespace = "{{ label.com\\.hashicorp\\.nomad\\.namespace }}"
labels.node = "{{ label.com\\.hashicorp\\.nomad\\.node_name }}"
# remove fields that have been converted to labels to avoid having the field twice
remove_label_fields = true
        EOH
      }
      service {
        check {
          port     = "api"
          type     = "http"
          path     = "/health"
          interval = "30s"
          timeout  = "5s"
        }
      }
      kill_timeout = "30s"
    }
  }
}
