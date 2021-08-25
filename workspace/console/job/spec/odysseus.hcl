job "odysseus" {
  datacenters = ["roger"]
  type = "service"

  group "joplin" {
    network {
      port "http" {
        to = 22300
      }
      port "db" {
        to = 5432
      }
    }

    service {
      name = "odysseus"
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

    task "server" {
      driver = "docker"

      env {
        APP_BASE_URL = "https://odysseus.zenq.me"
      }

      config {
        image = "joplin/server:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }

    task "db" {
      driver = "docker"

      config {
        image = "postgres:latest"
        ports = ["db"]
      }

      env {
        POSTGRES_USER = "odysseus"
        POSTGRES_DB = "odysseus"
      }

      vault {
        policies = ["${policy}"]
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/postgres/odysseus"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
