#!/usr/bin/env bash
#
# Install ansible
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install -y curl git software-properties-common ansible

# Pull ansible and run local.yml playbook
ansible-pull -U https://github.com/andrenbrandao/dev-env-setup.git

