####################################
### Load Configuration Variables
####################################
require 'yaml'
$vconfig = YAML::load_file("config/config.yaml")

Vagrant.configure("2") do |config|

	config.vagrant.host = :detect
	config.ssh.shell = $vconfig['vagrant']['ssh_shell']
	config.ssh.username = $vconfig['vagrant']['ssh_username']
	config.ssh.guest_port = $vconfig['vagrant']['ssh_port']
	config.ssh.keep_alive = true

	####################################
	### Machine Setup
	####################################
	config.vm.box = $vconfig['vagrant']['box']
	config.vm.box_url = $vconfig['vagrant']['box_url']
	config.vm.network "private_network", ip: $vconfig['vagrant']['box_ip']
	config.vm.hostname = $vconfig['vagrant']['vm_hostname']
	config.vm.network "forwarded_port", guest: 80, host: $vconfig['vagrant']['box_port']
	config.vm.network "forwarded_port", guest: 3306, host: $vconfig['mysql']['port']
	config.vm.network "forwarded_port", guest: 443, host: $vconfig['vagrant']['box_port_ssl']
	config.vm.network :forwarded_port, guest: 22, host: $vconfig['vagrant']['ssh_port'], id: "ssh"
	config.vm.synced_folder $vconfig['vagrant']['vm_webroot'], $vconfig['vagrant']['vm_docroot'], :nfs => true
	#config.vm.synced_folder $vconfig['vagrant']['vm_webroot'], $vconfig['vagrant']['vm_docroot'], :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=777","fmode=777"]
	#config.puppet_install.install_url = 'https://apt.puppetlabs.com/puppetlabs-release-trusty.deb'
	#config.puppet_install.puppet_version = :latest
  
	####################################
	### VirtualBox Provider
	####################################
	config.vm.provider "virtualbox" do |virtualbox|
		virtualbox.customize ["modifyvm", :id, "--cpuexecutioncap", $vconfig['vagrant']['vm_cpu']]
		virtualbox.customize ["modifyvm", :id, "--name", $vconfig['vagrant']['vm_name']]
		virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		virtualbox.customize ["modifyvm", :id, "--memory", $vconfig['vagrant']['vm_memory']]
		virtualbox.customize ["modifyvm", :id, "--rtcuseutc", "on"]
		virtualbox.customize ["setextradata", :id, "--VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
	end

	####################################
	### Shell Provisioning
	####################################
	config.vm.provision "shell" do |s|
		s.path = "config/shell/default.sh"
	end

	####################################
	### Puppet Provisioning
	####################################
	config.vm.provision "puppet" do |puppet|
		puppet.facter = {
			"phpmodules" => $vconfig['phpmodules'].join(','),
			"fqdn" 	     => $vconfig['vagrant']['vm_hostname'],
			"xdebug"     => $vconfig['xdebug'].join("\n")+"\n",
			"password"   => $vconfig['mysql']['password']
		}
		puppet.manifests_path = 'puppet/manifests'
		puppet.module_path = 'puppet/modules'
		puppet.manifest_file = 'init.pp'
		puppet.options = "--verbose"
	end

	####################################
	### Restart NGINX
	####################################
	config.vm.provision "shell",
    	inline: "sudo service nginx restart"

	####################################
	### Restart php-fpm
	####################################
	config.vm.provision "shell",
    	inline: "sudo service php5-fpm restart"

	####################################
	### Run SQL
	####################################
	config.vm.provision "shell",
	inline: "mysql -uroot < '/etc/mysql/remote.sql'"

	####################################
	### Ready
	####################################
	config.vm.provision "shell",
    	inline: "cat /vagrant/config/shell/ready.txt"
end
