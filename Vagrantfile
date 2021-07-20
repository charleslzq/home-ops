Vagrant.configure("2") do |config|
    config.vm.box = "charleslzq/packer-consul-vault"
    config.vm.box_version = "1.0.0"
    config.vm.network "forwarded_port", guest: 8500, host: 8500
    config.vm.network "forwarded_port", guest: 8200, host: 8200
end
