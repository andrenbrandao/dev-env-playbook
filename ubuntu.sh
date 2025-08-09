#!/bin/bash

# --- Argument Parsing ---
VAULT_PASS=$1
DEV_MODE=false
if [ "$2" = "--dev" ]; then
  DEV_MODE=true
fi

# --- Main Logic ---
run_playbook() {
  echo "Running the Ubuntu playbook..."
  if [ -z "$VAULT_PASS" ]; then
    ansible-playbook ubuntu.yml --ask-vault-pass
  else
    ansible-playbook ubuntu.yml --vault-password-file <(echo "$VAULT_PASS")
  fi
}

if ! command -v ansible >/dev/null; then
  echo "Ansible not found. Installing..."
  sudo apt-get update -y
  sudo apt-get install -y curl git software-properties-common ansible
fi

# --- Environment Execution ---
if [ "$DEV_MODE" = true ]; then
  echo "Running in local development mode."
  run_playbook
else
  echo "Running in production mode (cloning repo)."

  if [ -d "/tmp/dev-env-playbook" ]; then
    rm -rf /tmp/dev-env-playbook
  fi

  echo "Cloning the dev-env-playbook repository..."
  git clone https://github.com/andrenbrandao/dev-env-playbook.git /tmp/dev-env-playbook

  OLDPWD=$(pwd)
  cd /tmp/dev-env-playbook || exit 1

  run_playbook

  cd "$OLDPWD" || exit 1
fi
