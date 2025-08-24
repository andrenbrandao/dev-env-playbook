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

if [ "$OS_ID" != "ubuntu" ] && [ "$OS_ID" != "arch" ] && [ "$OS_ID" != "debian" ]; then
    echo "This playbook is designed for Ubuntu, Arch or Debian, but you are running $OS_ID. Exiting."
    exit 1
fi

if [ "$OS_ID" == "ubuntu" ] || [ "$OS_ID" == "debian" ]; then
  echo "Installing curl"
  sudo apt-get install -y curl
fi

install_gum() {
  echo "Installing gum..."

  if [ "$OS_ID" = "ubuntu" ] || [ "$OS_ID" = "debian" ]; then
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
if [ "$OS_ID" == "debian" ]; then
    gum style --foreground 212 'Debian detected. Only Custom CLI Setup is available.'
    echo
    CHOICE="Custom CLI Setup (For remote servers or specific tools, uses public dotfiles)"
else
    CHOICE=$(gum choose "Full Desktop Setup (Recommended for new machines)" "Custom CLI Setup (For remote servers or specific tools, uses public dotfiles)")
fi

if [ -z "$CHOICE" ]; then
    gum style --foreground 212 'No installation type selected. Exiting.'
    exit 0
fi

ubuntu_installer() {
  if [ "$DEV_FLAG" == "--dev" ]; then
    ./install.sh "$@"
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/install.sh)" _ "$@"
  fi
}

arch_installer() {
  if [ "$DEV_FLAG" == "--dev" ]; then
    ./install.sh "$@"
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/install.sh)" _ "$@"
  fi
}

install_full_desktop() {
  local args=("--dotfiles-mode" "private")
  if [ "$DEV_FLAG" == "--dev" ]; then
    args+=("--dev")
  fi

  if [ "$OS_ID" == "ubuntu" ]; then
    gum confirm "This will install a complete Ubuntu desktop environment. Are you sure?" || exit 0
    ubuntu_installer "${args[@]}"
  elif [ "$OS_ID" == "arch" ]; then
    gum confirm "This will install a complete Arch desktop environment. Are you sure?" || exit 0
    arch_installer "${args[@]}"
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

    TAGS=$(echo "$SELECTED_TAGS" | tr '\n' ',' | sed 's/,$//')
    args=("--dotfiles-mode" "public" "--tags" "$TAGS")
    if [ "$DEV_FLAG" == "--dev" ]; then
      args+=("--dev")
    fi

    if [ "$OS_ID" == "ubuntu" ] || [ "$OS_ID" == "debian" ]; then
      ubuntu_installer "${args[@]}"
    elif [ "$OS_ID" == "arch" ]; then
      arch_installer "${args[@]}"
    fi
fi

exit 0
