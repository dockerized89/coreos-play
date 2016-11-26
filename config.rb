# Size of the CoreOS cluster created by Vagrant
# Number of masters
$master_instances=1
# Number of minions
$minion_instances=1

# Box settings
$update_channel = "main"
$image_version = "trusty"


# Change basename of the VM
$instance_name_prefix="dev"


# Enable port forwarding of Docker TCP socket
# Set to the TCP port you want exposed on the *host* machine, default is 2375
# If 2375 is used, Vagrant will auto-increment (e.g. in the case of $num_instances > 1)
# You can then use the docker tool locally by setting the following env var:
#   export DOCKER_HOST='tcp://127.0.0.1:2375'
$expose_docker_tcp=2375

# Enable NFS sharing of your home directory ($HOME)
# It will be mounted at the same path in the VM as on the host.
# Example: /Users/foobar -> /Users/foobar
#$share_home=true

# Customize VMs
#$vm_gui = false
$vm_master_memory = 3072
$vm_master_cpus = 4
$vm_minion_memory = 3072
$vm_minion_cpus = 4

# Share additional folders to the VMs
# For example,
# $shared_folders = {'/path/on/host' => '/path/on/guest', '/home/foo/app' => '/app'}
# or, to map host folders to guest folders of the same name,
# $shared_folders = Hash[*['/home/foo/app1', '/home/foo/app2'].map{|d| [d, d]}.flatten]
$shared_folders = {'apps' => '/apps'}

# Enable port forwarding from guest(s) to host machine, syntax is: { 80 => 8080 }, auto correction is enabled by default.
#$forwarded_ports = {}

# Ansible provision settings
# Provision playbook location
$ansible_playbook='ansible/infra.yml'
# Inventory path - will be written from vagrantfile
$ansible_inventory='ansible/inventory/vagrant'

# IP range
$ip_range='192.168.51.'
# IP start from
$ip_start=50
