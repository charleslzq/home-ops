#!/bin/bash

set -e

DAY=$(date +%y%m%d)
FILE=${name}-dump-$(date +%y%m%d%H%M%S).sqlite
TARGET=/mnt/cifs/backup/$DAY/${name}/db
if [ ! -f $TARGET ]
then
    sudo mkdir -p $TARGET
fi

sqlite3 $database ".backup '$FILE'"
sudo mv $FILE $TARGET
