#!/bin/sh

set -ex

sed -i "/#PermitRootLogin/c\PermitRootLogin yes" /etc/ssh/sshd_config
/etc/init.d/sshd restart