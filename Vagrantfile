Vagrant.configure("2") do |config|
  config.vm.box = "charleslzq/hashi-stack"
  config.vm.box_version = "1.0.0"

  config.vm.hostname = "home-infra"
  config.vm.synced_folder "workspace/", "/home/vagrant/workspace", create: true, owner: "vagrant", group: "vagrant"
  config.vm.network "forwarded_port", guest: 8500, host: 8500
  config.vm.network "forwarded_port", guest: 8200, host: 8200
end
