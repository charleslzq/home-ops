#!/bin/bash

set -e

FILE=${name}-dump-$(date +%y%m%d%H%M%S).tar
TARGET=/mnt/cifs/backup/${name}/db
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

pg_dump -Ft -c -U ${PGUSER} > $FILE
sudo mv $FILE $TARGET
