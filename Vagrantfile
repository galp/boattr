# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  #config.vm.box = 'jessie_puppet'
  config.vm.box = "debian8-puppet"
  config.vm.hostname  = 'boattr-vagrant'
  config.vm.network 'forwarded_port', guest: 3030, host: 3030 # dashboard
  config.vm.network 'forwarded_port', guest: 5984, host: 5984 # couchdb
  # config.vm.network "public_network", bridge: "wlan4", ip: "192.168.8.200"
  config.vm.provision 'puppet' do |puppet|
    puppet.manifests_path = 'provision/'
    puppet.module_path = ['provision/modules', 'modules']
    puppet.hiera_config_path = 'hiera/hiera.yaml'
    puppet.working_directory = '/vagrant'
    puppet.options = ["--parser=future"] 
  end
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '512'
  end
end
