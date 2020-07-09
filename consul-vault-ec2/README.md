# Vault Reference Architecture - Ansible and AWS

This stack deploys 3 node Vault cluster which in turn is using a 3 node Consul cluster for backend storage. In addition it uses a AWS KMS key for auto unseal. 

## Dependencies

This project has the following Ansible Roles:

* [consul_role](https://github.com/photosojourn/consul_role)
* [vault_role](https://github.com/photosojourn/ansible-vault)

## Install Notes

1. Before running TF, scale the Vault servers down to 0 in the TF Code
2. Deploy TF stack
3. Scale Vault back up and re run TF
4. Logon to a Vault box and run `vault operator init -recovery-shares=1 -recovery-threshold=1`
5. Restart other Vault servers. 