#!/bin/sh

#Install Ansible and Consul Module
add-apt-repository universe
apt update
apt-get install -y python3-pip
pip3 install ansible

cat << EOF > /tmp/requirements.yml
---
- name: consul_role
  scm: git
  src: git+https://github.com/photosojourn/consul_role.git
  version: master
- name: vault_role
  scm: git
  src: git+https://github.com/photosojourn/ansible-vault.git
  version: master
EOF

ansible-galaxy install -r /tmp/requirements.yml

cat << EOF > /tmp/playbook.yml
---
- name: Install Consul
  hosts: localhost
  vars:
    consul_version: 1.8.0
    consul_ip: 127.0.0.1
    consul_server_nodes:
     - provider=aws tag_key=Consul tag_value=true
    vault_version: 1.4.3
    vault_bin_path: /opt/vault/bin
    vault_config_path: /opt/vault/vault.d
    vault_plugin_path: /opt/vault/plugins
    vault_data_path: /opt/vault/data
    vault_awskms: true
    vault_awskms_key_id: ${key_id}

  roles:
    - consul_role
    - vault_role
EOF

ansible-playbook /tmp/playbook.yml
