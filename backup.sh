#!/bin/bash

cd ~
consul snapshot save consul-$(date +"%s").snap
sudo mv *.snap /vagrant/consul-backup/
