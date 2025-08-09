#!/bin/bash

# --- Argument Parsing ---
DEV_FLAG=""
if [ "$1" = "--dev" ]; then
  DEV_FLAG="--dev"
  echo "Running in Development Mode"
fi

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

install_gum() {
  echo "Installing gum..."

  if [ "$OS_ID" = "ubuntu" ]; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update -y && sudo apt install gum -y
  fi

  if [ "$OS_ID" = "arch" ]; then
    sudo pacman -Sy gum --noconfirm
  fi
}

# Ensure gum is installed
if ! command -v gum >/dev/null; then
  install_gum
fi

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Development Environment Setup' "Detected OS: $PRETTY_NAME" 'Choose your installation type.'

# --- Installation Type Selection ---
CHOICE=$(gum choose "Full Desktop Setup (Recommended for new machines)" "Custom CLI Setup (For remote servers or specific tools)")

if [ -z "$CHOICE" ]; then
    gum style --foreground 212 'No installation type selected. Exiting.'
    exit 0
fi

request_vault_password() {
  # --- Vault Password ---
  VAULT_PASSWORD=$(gum input --password --placeholder "Enter vault password...")
  if [ -z "$VAULT_PASSWORD" ]; then
    gum style --foreground 212 'Vault password is required. Exiting.'
    exit 0
  fi
}

install_full_desktop() {
  if [ "$OS_ID" == "ubuntu" ]; then
    gum confirm "This will install a complete Ubuntu desktop environment. Are you sure?" || exit 0
    request_vault_password
    ./ubuntu.sh "$VAULT_PASSWORD" "$DEV_FLAG"
  elif [ "$OS_ID" == "arch" ]; then
    gum confirm "This will install a complete Arch desktop environment. Are you sure?" || exit 0
    request_vault_password
    ./install.sh "$VAULT_PASSWORD" "$DEV_FLAG"
  fi
}

# --- Execute based on Install Type ---
if [ "$CHOICE" = "Full Desktop Setup (Recommended for new machines)" ]; then
  install_full_desktop
else
    SELECTED_TAGS=$(gum choose --no-limit \
         --selected "dotfiles,zsh,tmux,neovim,programming-languages,github-cli" \
         "dotfiles" "zsh" "tmux" "neovim" "programming-languages" "github-cli")

    if [ -z "$SELECTED_TAGS" ]; then
        echo "No components selected. Exiting."
        exit 0
    fi

    # If "dotfiles" was selected, we need to ask for the vault password.
    # We check for it separately to avoid issues with stdin redirection.
    if echo "$SELECTED_TAGS" | grep -q "dotfiles"; then
      request_vault_password
    fi

    TAGS=$(echo "$SELECTED_TAGS" | tr '\n' ',' | sed 's/,$//')
    ./install.sh "$VAULT_PASSWORD" "$TAGS" "$DEV_FLAG"
fi

exit 0
