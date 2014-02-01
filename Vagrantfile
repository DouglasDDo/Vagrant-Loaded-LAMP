#Vagrant Configuration
##########################################
Vagrant.configure("2") do |config|
	config.vm.box = "debian-wheezy71-x64-vbox42"
	config.vm.box_url = "https://dl.dropboxusercontent.com/u/86066173/debian-wheezy.box"
	config.vm.synced_folder "./", "/vagrant", id: "vagrant-root", :nfs => false

#VirtualBox Configuration
#########################################
	config.vm.provider :virtualbox do |virtualbox|
		virtualbox.customize ["modifyvm", :id, "--name", "BOXNAME"]
		virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		virtualbox.customize ["modifyvm", :id, "--memory", MEMORYSIZE]
		virtualbox.customize ["setextradata", :id, "--VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
	end


#Network Configuration
##########################################
	config.vm.network "private_network", ip: "IPADDRESS"
	config.vm.usable_port_range = (2200..2250)
	config.vm.network :forwarded_port, host: 8080, guest: 80

#Provisioning
##########################################
	config.vm.provision :shell, :path => "lamp.sh"
	config.vm.provision :shell, :path => "laravel.sh"
end
