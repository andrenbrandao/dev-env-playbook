#!/bin/bash

# --- Argument Parsing ---
TAGS=""
DEV_MODE=false
DOTFILES_MODE="private"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --tags)
      TAGS="$2"
      shift 2
      ;;
    --dev)
      DEV_MODE=true
      shift
      ;;
    --dotfiles-mode)
      DOTFILES_MODE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

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
    echo "This playbook is designed for Ubuntu or Arch, but you are running $OS_ID. Exiting."
    exit 1
fi

# --- Main Logic ---
run_playbook() {
  echo "Running the playbook for $OS_ID..."

  local playbook_file="cli.yml"
  if [ "$OS_ID" = "ubuntu" ]; then
    playbook_file="ubuntu.yml"
  fi

  local args=(-e "dotfiles_mode=$DOTFILES_MODE")
  if [ -n "$TAGS" ]; then
    args+=(--tags "$TAGS")
  fi

  # If dotfiles_mode is private, we need the vault pass and sudo password.
  if [ "$DOTFILES_MODE" = "private" ]; then
    ansible-playbook "$playbook_file" "${args[@]}" --ask-become-pass --ask-vault-pass
  else
    # For public dotfiles, no vault pass is needed, but need sudo password.
    ansible-playbook "$playbook_file" "${args[@]}" --ask-become-pass
  fi
}

install_ansible() {
  echo "Ansible not found. Installing..."
  if [ "$OS_ID" = "ubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y curl git software-properties-common ansible
  elif [ "$OS_ID" = "arch" ]; then
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
