#!/bin/bash

set -e

FILE=${name}-data-$(date +%y%m%d%H%M%S).tar
TARGET=/mnt/cifs/backup/${name}/data
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

sudo tar -zcvf $FILE $dir
sudo mv $FILE $TARGET
