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
    consul_server: true
    consul_server_count: 3
  roles:
    - consul_role
EOF

ansible-playbook /tmp/playbook.yml
