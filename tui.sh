#!/bin/bash

# Ensure gum is installed
if ! command -v gum >/dev/null; then
    echo "Installing gum..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update -y && sudo apt install gum -y
fi

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Welcome to the Dev Env Setup!' 'Choose your installation options.'

SELECTED_TAGS=""

# Main categories
CATEGORY=$(gum choose "CLI Setup" "Ubuntu")

if [ -z "$CATEGORY" ]; then
    gum style --foreground 212 'No category selected. Exiting.'
    exit 0
fi

# Check if dotfiles are included and prompt for vault password if needed
if [ "$CATEGORY" = "Ubuntu" ]; then

  VAULT_PASSWORD=$(gum input --password --placeholder "Enter vault password...")
  if [ -n "$VAULT_PASSWORD" ]; then
    ./ubuntu.sh "$VAULT_PASSWORD"
  else
    gum style --foreground 212 'Vault password is required for dotfiles installation. Exiting.'
  fi
else
  gum style --foreground 212 'CLI installation is not implemented yet.'
fi

exit 0
