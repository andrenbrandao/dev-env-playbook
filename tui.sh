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
    gum style --foreground 212 "Cannot determine operating system. Exiting."
    exit 1
fi

if [ "$OS_ID" != "ubuntu" ]; then
    gum style --foreground 212 "This playbook is designed for Ubuntu, but you are running $OS_ID. Exiting."
    exit 1
fi

# Ensure gum is installed
if ! command -v gum >/dev/null; then
    echo "Installing gum for Ubuntu..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update -y && sudo apt install gum -y
fi

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Ubuntu Dev Env Setup' "Detected OS: $PRETTY_NAME" 'Choose your installation type.'

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

# --- Execute based on Install Type ---
if [ "$CHOICE" = "Full Desktop Setup (Recommended for new machines)" ]; then
    gum confirm "This will install a complete Ubuntu desktop environment. Are you sure?" || exit 0
    request_vault_password
    ./ubuntu.sh "$VAULT_PASSWORD" "$DEV_FLAG"
else
    SELECTED_TAGS=$(gum choose --no-limit \
         "dotfiles" "zsh" "tmux" "neovim" "programming-languages" "github-cli")

    if [ -z "$SELECTED_TAGS" ]; then
        echo "No components selected. Exiting."
        exit 0
    fi

    while IFS= read -r tag; do
        if [ "$tag" = "dotfiles" ]; then
          request_vault_password
          break
        fi
    done <<< "$SELECTED_TAGS"

    TAGS=$(echo "$SELECTED_TAGS" | tr '\n' ',' | sed 's/,$//')
    ./install.sh "$VAULT_PASSWORD" "$TAGS" "$DEV_FLAG"
fi

exit 0
