# coreos-play

* Dynamically sized coreos cluster with SSL + firewall setup using Vagrant + Ansible.
* Docker swarm mode (Docker 1.12+) (Dynamic managers/workers depending on values from config.rb)

### Requirements
Generated ca.csr, ca-key.pem and ca.pem files placed in 'secure' ansible role.


### TODO
* SSL/TLS for docker 
* Auto generate certs for fleet/etcd when deploying new cluster..

