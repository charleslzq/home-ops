#!/bin/bash

set -e

FILE=odyssues-dump-$(date +%y%m%d%H%M%S).tar
TARGET=/mnt/cifs/backup/db/odyssues
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

pg_dump -Ft -c -U ${PGUSER} > $FILE
sudo mv $FILE $TARGET
