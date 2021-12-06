job "kouko" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "photoprism" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "shanks"
    }
    restart {
      attempts = 15
      delay    = "30s"
    }
    reschedule {
      attempts       = 15
      interval       = "10m"
      delay          = "5s"
      delay_function = "exponential"
      max_delay      = "30s"
      unlimited      = false
    }
    network {
      port "http" {
        to = 2342
      }
    }
    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    service {
      name = "kouko"
      tags = [
        "traefik.enable=true",
#        "traefik.http.routers.kouko.middlewares=yashin",
      ]
      port = "http"
    }

    task "photoprism" {
      driver = "docker"

      config {
        image = "photoprism/photoprism:latest"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/kouko/data:/photoprism/storage",
          "/opt/nomad/volume/shanks/data/data/charleslzq/files/Photos:/photoprism/originals",
        ]
        security_opt = [
          "seccomp=unconfined",
          "apparmor=unconfined",
        ]
#        dns_servers = [
#          "10.10.30.235"
#        ]
      }

      env {
        # File size limit for originals in MB (increase for high-res video)
        PHOTOPRISM_ORIGINALS_LIMIT = 1000
        # Improves transfer speed and bandwidth utilization (none or gzip)
        PHOTOPRISM_HTTP_COMPRESSION = "gzip"
        # Run in debug mode (shows additional log messages)
        PHOTOPRISM_DEBUG = true
        # No authentication required (disables password protection)
        PHOTOPRISM_PUBLIC = true
        # Don't modify originals directory (reduced functionality)
        PHOTOPRISM_READONLY = false
        # Enables experimental features
        PHOTOPRISM_EXPERIMENTAL = false
        # Disables built-in WebDAV server
        PHOTOPRISM_DISABLE_WEBDAV = false
        # Disables Settings in Web UI
        PHOTOPRISM_DISABLE_SETTINGS = false
        # Disables using TensorFlow for image classification
        PHOTOPRISM_DISABLE_TENSORFLOW = false
        # Enables Darktable presets and disables concurrent RAW conversion
        PHOTOPRISM_DARKTABLE_PRESETS = false
        # Flag photos as private that MAY be offensive (requires TensorFlow)
        PHOTOPRISM_DETECT_NSFW = false
        # Allow uploads that MAY be offensive
        PHOTOPRISM_UPLOAD_NSFW = true
        # Public PhotoPrism URL
        PHOTOPRISM_SITE_URL = "https://kouko.zenq.me/"
        PHOTOPRISM_SITE_TITLE = "Kouko"
        PHOTOPRISM_SITE_CAPTION = "Kouko"
        PHOTOPRISM_SITE_AUTHOR = "charleslzq"
        PHOTOPRISM_WORKERS = 1
      }

      template {
        data = <<EOH
PHOTOPRISM_ADMIN_PASSWORD={{with secret "home/data/default"}}{{.Data.data.password}}{{end}}
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 5000
        memory = 1500
      }
    }

    task "create-dir" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/create_dir.sh"]
      }

      volume_mount {
        volume = "host"
        destination = "/mnt/host"
        read_only = false
      }

      template {
        data = <<EOH
sudo mkdir -p /mnt/host/kouko/data
sudo chmod -R 777 /mnt/host/kouko/data
EOH
        destination = "local/create_dir.sh"
        change_mode = "noop"
      }

      lifecycle {
        hook = "prestart"
      }
    }
  }
}
