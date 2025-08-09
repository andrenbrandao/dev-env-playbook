#!/bin/bash

# --- Argument Parsing ---
VAULT_PASS=$1
TAGS=$2
DEV_MODE=false

# Check for --dev flag, which can be in arg 2 or 3
if [ "$2" = "--dev" ] || [ "$3" = "--dev" ]; then
  DEV_MODE=true
fi
# If --dev was in $2, then tags are not present
if [ "$2" = "--dev" ]; then
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
    for tag in $TAGS; do
      if [ "$tag" = "dotfiles" ]; then
        return 0
      fi
    done
    return 1
}

  if [ -z "$VAULT_PASS" ] && contains_dotfiles; then
    # Vault pass missing AND dotfiles tag present → ask vault pass
    ansible-playbook cli.yml --ask-vault-pass "${args[@]}"
  elif [ -z "$VAULT_PASS" ]; then
    # Vault pass missing AND no dotfiles tag → just run without vault pass args
    ansible-playbook cli.yml "${args[@]}"
  else
    # Vault pass provided → use vault-password-file
    ansible-playbook cli.yml --vault-password-file <(echo "$VAULT_PASS") "${args[@]}"
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
