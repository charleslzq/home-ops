runcmd:
  - sudo apt-get update
  - sudo apt-get install -y zip curl
  - cd /tmp/
  - curl -sSL  https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip > consul.zip
  - unzip consul.zip
  - sudo chmod +x consul
  - sudo mv consul /usr/local/bin/
  - rm /tmp/consul.zip
