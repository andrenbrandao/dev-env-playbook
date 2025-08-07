#!/bin/sh

# Install ansible
sudo apt-get update -y
sudo apt-get install -y curl git software-properties-common ansible

# Clone repo
echo "Cloning the dev-env-playbook repository..."
git clone https://github.com/andrenbrandao/dev-env-playbook.git /tmp/dev-env-playbook

OLDPWD=$(pwd)
cd /tmp/dev-env-playbook || {
  echo "Failed to cd to /tmp/dev-env-playbook"
  exit 1
}

# Pull ansible and run cli.yml playbook
echo "Running the CLI playbook..."
ansible-playbook cli.yml --ask-vault-pass

cd "$OLDPWD" || exit 1

