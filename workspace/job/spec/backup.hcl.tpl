job "backup-daily" {
  datacenters = ["roger"]
  type        = "batch"
  periodic {
    cron             = "0 0 * * * *"
    prohibit_overlap = true
    time_zone = "Asia/Shanghai"
  }

  group "consul" {
    volume "cifs" {
      type      = "host"
      source    = "cifs"
      read_only = false
    }

    constraint {
      attribute = "$${meta.node_type}"
      value     = "gateway"
    }

    vault {
     policies = ["${policy}"]
   }

    task "consul_backup" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/backup_consul.sh"]
      }

      volume_mount {
        volume      = "cifs"
        destination = "/mnt/cifs"
        read_only   = false
      }

      template {
        data = <<EOH
CONSUL_HTTP_TOKEN="{{with secret "consul/creds/consul-server-role"}}{{.Data.token}}{{end}}"
EOH
        destination = "secrets/consul.env"
        env = true
      }

      template {
        data = <<EOH
${backup_script}
EOH
        destination   = "local/backup_consul.sh"
        change_mode   = "noop"
      }

      logs {
        max_files     = 3
        max_file_size = 10
      }
    }
  }
}
