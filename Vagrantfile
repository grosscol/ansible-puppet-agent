Vagrant.configure("2") do |config|

  # Create host for puppet master to run on
  config.vm.define 'puppet' do |machine|
    machine.vm.hostname = 'puppet'
    machine.vm.box = "debian/jessie64"
    machine.vm.network "private_network", ip: "192.168.90.10"
    machine.vm.synced_folder ".", "/vagrant", disabled: true
    machine.vm.provider "virtualbox" do |v|
      v.memory = 3072
    end
  end

  # Create host for puppet agent
  config.vm.define 'dum' do |machine|
    machine.vm.hostname = 'dum'
    machine.vm.box = "debian/jessie64"
    machine.vm.network "private_network", ip: "192.168.90.20"
    machine.vm.synced_folder ".", "/vagrant", disabled: true
    machine.vm.provider "virtualbox" do |v|
      v.memory = 1024
    end
  end
  
  # Create host for puppet client to run on
  #   Do provisioning for all hosts in the block of the last vm definition.
  #   This allows ansible to run only once and ensures all the hosts have been provisioned.
  #   It's a hack to do "common provisioning for multi machine setups"
  config.vm.define 'dee' do |machine|
    machine.vm.hostname = 'dee'
    machine.vm.box = "debian/jessie64"
    machine.vm.network "private_network", ip: "192.168.90.30"
    machine.vm.synced_folder ".", "/vagrant", disabled: true
    machine.vm.provider "virtualbox" do |v|
      v.memory = 1024
    end
    machine.vm.provision "ansible" do |ansible|
      ansible.limit = "all"
      ansible.verbose = "v"
      ansible.playbook = "vagrant.playbook.yml"
			ansible.groups = {
				"puppet_master" => ["puppet"],
				"puppet_agent" => ["dum","dee"],
        "puppet_agent:vars" => {"pa_master_addr" => "192.168.90.10", 
                                "pa_master_fqdn" => "puppet"}
			}
    end
  end
end
