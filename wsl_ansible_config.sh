#!/bin/bash

# Remove and recreate /etc/resolv.conf
sudo rm -rf /etc/resolv.conf
sudo touch /etc/resolv.conf

# Add nameserver and search domain to /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "search example.com" | sudo tee -a /etc/resolv.conf

# Create /etc/apt/apt.conf.d/proxy.conf and add proxy settings
echo 'Acquire::http::Proxy "http://proxy.example.com:8080/";' | sudo tee /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Proxy "https://proxy.example.com:8080/";' | sudo tee -a /etc/apt/apt.conf.d/proxy.conf

# Add proxy environment variables to ~/.bashrc if they don't already exist
grep -qxF 'export http_proxy="http://proxy.example.com:8080/"' ~/.bashrc || echo 'export http_proxy="http://proxy.example.com:8080/"' >> ~/.bashrc
grep -qxF 'export https_proxy="http://proxy.example.com:8080/"' ~/.bashrc || echo 'export https_proxy="http://proxy.example.com:8080/"' >> ~/.bashrc
grep -qxF 'export no_proxy="127.0.0.1,localhost,example.com"' ~/.bashrc || echo 'export no_proxy="127.0.0.1,localhost,example.com"' >> ~/.bashrc

# Apply proxy settings without needing to restart the shell
export http_proxy="http://proxy.example.com:8080/"
export https_proxy="http://proxy.example.com:8080/"
export no_proxy="127.0.0.1,localhost,example.com"

# Update and upgrade the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Python and required packages
sudo apt-get install -y python3 python3-pip

# Upgrade pip
python3 -m pip install --upgrade pip

# Install Ansible
sudo -E pip3 install ansible

# Check Ansible version
ansible --version

# Install pywinrm to enable Ansible to communicate over WinRM
sudo -E pip3 install pywinrm

# Create the desired folder structure
mkdir -p ~/ansible/group_vars/all

# Create or overwrite the vars.yml file with new content
echo "# Credentials
dev_user: \"{{ vault_dev_user }}\"
dev_password: \"{{ vault_dev_password }}\"
git_user: \"{{ vault_git_user }}\"
git_password: \"{{ vault_git_password }}\"
admin_user: \"{{ vault_admin_user }}\"
admin_password: \"{{ vault_admin_password }}\"" > ~/ansible/group_vars/all/vars.yml

# Create or overwrite the vault.yml file with new content
echo "# vault.yml
vault_dev_user: example\\dev_user
vault_dev_password: 
vault_git_user: git_user
vault_git_password: 
vault_admin_user: admin_user
vault_admin_password: " > ~/ansible/group_vars/all/vault.yml

# Create or overwrite the vault password file
touch ~/ansible/group_vars/all/vault_pw.txt

# Create or overwrite the inventory_file_template.yml file with new content
cat << EOF > ~/ansible/inventory_file_template.yml
---
windows:
  hosts:
    #server01.example.com:
    #server02.example.com:
    #server03.example.com:
	
  vars:
    ansible_connection: winrm
    ansible_winrm_transport: ntlm
    ansible_winrm_server_cert_validation: ignore
    ansible_port: 5985
EOF
