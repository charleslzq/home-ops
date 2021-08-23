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
