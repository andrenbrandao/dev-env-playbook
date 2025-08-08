#!/bin/bash

# Install ansible
sudo apt-get update -y
sudo apt-get install -y curl git software-properties-common ansible

# Clone repo
if [ -d "/tmp/dev-env-playbook" ]; then
  rm -rf /tmp/dev-env-playbook
fi

echo "Cloning the dev-env-playbook repository..."
git clone https://github.com/andrenbrandao/dev-env-playbook.git /tmp/dev-env-playbook

OLDPWD=$(pwd)
cd /tmp/dev-env-playbook || {
  echo "Failed to cd to /tmp/dev-env-playbook"
  exit 1
}

# Pull ansible and run cli.yml playbook
echo "Running the CLI playbook..."

if [ -z "$1" ]; then
  ansible-playbook cli.yml --ask-vault-pass
else
  ansible-playbook cli.yml --vault-password-file <(echo "$1")
fi

cd "$OLDPWD" || exit 1

