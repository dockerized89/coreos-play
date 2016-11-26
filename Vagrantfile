# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.8.5"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# Defaults for config options defined in CONFIG
$master_instances = 1
$minion_instances = 1
$instance_name_prefix = "dev"
$update_channel = "main"
$image_version = "trusty"
$share_home = false
$vm_master_memory = 1024
$vm_master_cpus = 1
$vm_minion_memory = 1024
$vm_minion_cpus = 1
$shared_folders = {}
$forwarded_ports = {}

$os_image = (ENV['OS_IMAGE'] || "centos7").to_sym
$coreos_update_channel = "alpha"
$coreos_image_version = "current"


# Ansible inventory file string
$inventory = ""
# Instances array
$instances = Array.new

if File.exist?(CONFIG)
  require CONFIG
end

$num_instances = $master_instances + $minion_instances

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  #config.vm.box = "ubuntu/#{$image_version}64"
  config.vm.box = "coreos-%s" % $coreos_update_channel
  if $coreos_image_version != "current"
     config.vm.box_version = $coreos_image_version
  end


  #config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]

  #["vmware_fusion", "vmware_workstation"].each do |vmware|
  #  config.vm.provider vmware do |v, override|
  #    override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant_vmware_fusion.json" % [$update_channel, $image_version]
  #  end
  #end

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  (1..$num_instances).each do |i|
    # Kubernetes node role
    role = i <= $master_instances ? "master" : "minion"
    # Number of instance
    instance_num = role == "master" ? i : (i - $master_instances)
    # Store instance info for global use
    $instances[i] = {
      "name" => "#{$instance_name_prefix}-#{role}-#{instance_num}",
      "hostname" => "#{role}-#{instance_num}.#{$instance_name_prefix}.den",
      "role" => role,
      "num" => instance_num,
      "ip" => "#{$ip_range}#{i + $ip_start}"
    }
    config.vm.define vm_name = $instances[i]['name'] do |config|
      config.vm.hostname = $instances[i]['hostname']

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        #["vmware_fusion", "vmware_workstation"].each do |vmware|
        #  config.vm.provider vmware do |v, override|
        #    v.vmx["serial0.present"] = "TRUE"
        #    v.vmx["serial0.fileType"] = "file"
        #    v.vmx["serial0.fileName"] = serialFile
        #    v.vmx["serial0.tryNoRxLoss"] = "FALSE"
        #  end
        #end

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

      $forwarded_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.memory = $role == "master" ? $vm_master_memory : $vm_minion_memory
        vb.cpus = $role == "master" ? $vm_master_cpus : $vm_minion_cpus
        # Use faster paravirtualized networking
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
      end
      config.vm.network :private_network, ip: $instances[i]['ip']

      if $share_home
        config.vm.synced_folder ENV['PWD'], ENV['HOME'], id: "pwd", :nfs => true, :mount_options => ['nolock,vers=3,udp']
      end

      if File.exist?(CLOUD_CONFIG_PATH)
        config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
        config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
      end

       # Gather hosts into inventory pool
      if $instances[i]['num'] == 1 then
        $inventory.concat "\n[#{$instances[i]['role']}]\n"
      end
      $inventory.concat "#{$instances[i]['ip']}\n"

      # Run ansible tasks after last host is created
      if i == $num_instances then

        # Write local ansible inventory
        File.open($ansible_inventory ,'w') do |f|
          $inventory.concat "\n[vagrant:children]\nmaster\nminion\n\n[swarm-master:children]\nmaster\n\n[swarm:children]\nminion\n"
          f.write $inventory
        end

        # Provision hosts
        config.vm.provision "ansible" do |ansible|
          ansible.playbook = $ansible_playbook
          ansible.inventory_path = $ansible_inventory
          ansible.limit = 'all'
        end
      end

    end
  end
end
