job "backup" {
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
      attribute = "${meta.node_type}"
      value     = "gateway"
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
#!/bin/bash

set -e

FILE=consul-$(date +%y%m%d%H%M%S).snap
TARGET=/mnt/cifs/backup/consul
if [ ! -f $TARGET ]
then
    mkdir -p $TARGET
fi

consul snapshot save $FILE
sudo mv $FILE $TARGET
EOH
        destination   = "local/backup_consul.sh"
        change_mode   = "noop"
      }

      resources {
        cpu    = 20
        memory = 200
      }

      logs {
        max_files     = 3
        max_file_size = 10
      }
    }
  }
}