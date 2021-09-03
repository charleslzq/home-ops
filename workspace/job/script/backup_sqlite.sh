#!/bin/bash

set -e

FILE=${name}-dump-$(date +%y%m%d%H%M%S).sqlite
TARGET=/mnt/cifs/backup/db/${name}
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

sqlite3 $database ".backup '$FILE'"
sudo mv $FILE $TARGET
