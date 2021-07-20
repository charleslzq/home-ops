#!/bin/bash

set -e

cget() { curl -sf "http://127.0.0.1:8500/v1/kv/service/vault/$1?raw"; }


