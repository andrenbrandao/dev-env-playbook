#!/bin/bash

# --- Argument Parsing ---
TAGS=$1
DEV_MODE=false

# Check for --dev flag, which can be in arg 1 or 2
if [ "$1" = "--dev" ] || [ "$2" = "--dev" ]; then
  DEV_MODE=true
fi
# If --dev was in $1, then tags are not present
if [ "$1" = "--dev" ]; then
  TAGS=""
fi

# --- Main Logic ---
run_playbook() {
  echo "Running the CLI playbook..."

  local args=()
  if [ -n "$TAGS" ]; then
    args+=(--tags "$TAGS")
  fi

  # Function to check if "dotfiles" is in TAGS
  contains_dotfiles() {
    IFS=',' read -ra arr <<< "$TAGS"
    for tag in "${arr[@]}"; do
      if [ "$tag" = "dotfiles" ]; then
        return 0
      fi
    done
    return 1
  }

  # If no tags are selected OR 'dotfiles' tag is present,
  # prompt for Vault password and Become password
  if [ -z "$TAGS" ]  || contains_dotfiles; then
    ansible-playbook cli.yml --ask-vault-pass "${args[@]}" --ask-become-pass

  # If tags are present but 'dotfiles' is not among them,
  # only prompt for Become password (no Vault password needed)
  else
    ansible-playbook cli.yml "${args[@]}" --ask-become-pass
  fi
}

install_ansible() {
  echo "Ansible not found. Installing..."

  # --- OS Detection ---
  if [ -f /etc/os-release ]; then
      # shellcheck source=/dev/null
      . /etc/os-release
      OS_ID=$ID
  else
      echo "Cannot determine operating system. Exiting."
      exit 1
  fi

  if [ "$OS_ID" != "ubuntu" ] && [ "$OS_ID" != "arch" ]; then
      echo "This playbook is designed for Ubuntu, but you are running $OS_ID. Exiting."
      exit 1
  fi

  if [ "$OS_ID" = "ubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y curl git software-properties-common ansible
  fi

  if [ "$OS_ID" = "arch" ]; then
    sudo pacman -Syu --noconfirm ansible git
  fi

}

if ! command -v ansible >/dev/null; then
  install_ansible
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
