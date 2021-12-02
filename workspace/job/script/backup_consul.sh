#!/bin/bash

set -e

DAY=$(date +%y%m%d)
FILE=consul-$(date +%y%m%d%H%M%S).snap
TARGET=/mnt/cifs/backup/$DAY/consul
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

consul snapshot save $FILE
sudo mv $FILE $TARGET
