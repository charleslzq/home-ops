job "odysseus" {
  datacenters = ["roger"]
  type = "service"

  group "joplin" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "1d"
    }

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

    task "db" {
      driver = "docker"

      config {
        image = "postgres:latest"
        ports = ["db"]
        volumes = [
          "/opt/nomad/volume/db/odysseus:/var/lib/postgresql/data",
        ]
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

    task "server" {
      driver = "docker"

      env {
        APP_BASE_URL = "https://odysseus.zenq.me"
        DB_CLIENT= "pg"
        POSTGRES_USER = "odysseus"
        POSTGRES_DATABASE = "odysseus"
        POSTGRES_HOST="$${NOMAD_IP_db}"
        POSTGRES_PORT="$${NOMAD_HOST_PORT_db}"
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
  }
}
