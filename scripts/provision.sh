#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y software-properties-common ntpdate
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible
