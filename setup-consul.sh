#!/bin/bash

mkdir -p ~/consul-backup
cd ~/consul-backup
consul snapshot save consul-$(date +"%s").snap

BACKUP_BASE="/vagrant/consul-backup/"
latest_backup=$(ls -t $BACKUP_BASE | head -1)
if [ ! $latest_backup ]
then
    echo "Unable to find latest backup file"
    exit 1
fi

cd ~
full_path="$BACKUP_BASE$latest_backup"
sudo cp $full_path .
consul snapshot restore $latest_backup
sudo rm *.snap
