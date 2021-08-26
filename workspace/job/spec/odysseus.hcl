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

    vault {
      policies = ["${policy}"]
    }

    task "server" {
      driver = "docker"

      env {
        APP_BASE_URL = "https://odysseus.zenq.me"
        DB_CLIENT= "pg"
        POSTGRES_USER = "odysseus"
        POSTGRES_DB = "odysseus"
        POSTGRES_HOST="$${NOMAD_IP_db}"
        POSTGRES_PORT="$${NOMAD_PORT_db}"
      }

      config {
        image = "joplin/server:latest"
        ports = ["http"]
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/postgres/odysseus"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu    = 300
        memory = 512
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
