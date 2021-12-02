#!/bin/bash

set -e

DAY=$(date +%y%m%d)
FILE=${name}-dump-$(date +%y%m%d%H%M%S).tar
TARGET=/mnt/cifs/backup/$DAY/${name}/db
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

pg_dump -Ft -c -U ${PGUSER} > $FILE
sudo mv $FILE $TARGET
