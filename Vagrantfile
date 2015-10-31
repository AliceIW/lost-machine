# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.network :forwarded_port, guest: 80, host: 2011
  config.vm.network :forwarded_port, guest: 3306, host: 33060, auto_correct: true

  config.vm.network "private_network", type: "dhcp"

   config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     vb.gui = false

     # Customize the amount of memory on the VM:
     vb.memory = "512"
   end

   config.vm.provision :shell, path: "bootstrap.sh"

end
