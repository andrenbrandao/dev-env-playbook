#!/usr/bin/env bash
#
# Install ansible
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install -y curl git software-properties-common ansible

# Clone repo
echo "Cloning the dev-env-playbook repository..."
git clone https://github.com/andrenbrandao/dev-env-playbook.git /tmp/dev-env-playbook

# Pull ansible and run local.yml playbook
pushd /tmp/dev-env-playbook
echo "Running the local playbook..."
ansible-playbook local.yml --ask-vault-pass
popd

