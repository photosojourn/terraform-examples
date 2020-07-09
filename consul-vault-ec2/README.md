# Vault Reference Architecture - Ansible and AWS

This stack deploys 3 node Vault cluster which in turn is using a 3 node Consul cluster for backend storage. In addition it uses a AWS KMS key for auto unseal. 

## Dependencies

This project has the following Ansible Roles:

* [consul_role](https://github.com/photosojourn/consul_role)
* [vault_role](https://github.com/photosojourn/ansible-vault)